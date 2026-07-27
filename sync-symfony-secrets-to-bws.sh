#!/usr/bin/env bash
# Export Symfony secrets from one Symfony environment into one Bitwarden
# Secrets Manager project. Project-agnostic: run from any Symfony project
# root (i.e. wherever its docker-compose.yml lives). Requires: docker with
# the compose plugin. jq itself runs via docker too (see JQ_DOCKER_IMAGE).
#
# Written against bash 3.2 (macOS default) for portability: no mapfile/
# readarray, no associative arrays.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: sync-symfony-secrets-to-bws.sh [sync] [-e ENV] [-p PROJECT_ID] [-m METHOD] [-s SERVICE] [-y] [-h]
       sync-symfony-secrets-to-bws.sh print-ansible-vars [-p PROJECT_ID] [-h]

Subcommands:
  sync               (default) Export Symfony secrets from one environment
                     into one Bitwarden Secrets Manager project, creating or
                     updating secrets as needed. Afterwards, also prints the
                     "print-ansible-vars" mapping (below) for that project.
  print-ansible-vars Prints, as YAML on stdout, an Ansible variables mapping
                     for every secret currently in a Bitwarden Secrets
                     Manager project, in the form consumed by the lephare
                     Ansible role (see e.g.
                     ansible/preprod/group_vars/admin/vars):
                       lephare_bitwarden_secrets:
                         some_secret: "{{ lookup('bitwarden.secrets.lookup', '<id>', base_url='...', api_url='...', identity_url='...') }}"
                     Only the mapping itself goes to stdout -- every other
                     message (prompts, status lines) goes to stderr -- so
                     this can be redirected straight into an Ansible vars
                     file, e.g.:
                       ./sync-symfony-secrets-to-bws.sh print-ansible-vars -p PROJECT_ID > snippet.yml

Common options:
  -p PROJECT_ID  Bitwarden Secrets Manager project UUID (prompted if omitted,
                 with the option to create a new project)
  -h             Show this help and exit

sync-only options:
  -e ENV         Symfony environment to export (prompted if omitted)
  -m METHOD      Secret source method: table (default) or decrypt-to-local
  -s SERVICE     Docker Compose service used to run bin/console (default: php)
  -y             Assume "yes" when a secret already exists (overwrite
                 without asking)

Environment variables:
  BWS_ACCESS_TOKEN           (required) Bitwarden Secrets Manager access token
  BWS_SERVER_URL             Bitwarden server/region (default: https://vault.bitwarden.eu)
  BWS_IDENTITY_URL           Identity server used in print-ansible-vars output
                             (default: BWS_SERVER_URL with a "vault." prefix
                             replaced by "identity.")
  BWS_DOCKER_IMAGE           bws CLI docker image (default: ghcr.io/bitwarden/bws:latest)
  BWS_SHELL_DOCKER_IMAGE     Image with both a shell and the bws binary, used
                             only for `secret create`/`edit` (default:
                             lephare/ansible:latest).
  JQ_DOCKER_IMAGE            jq docker image (default: ghcr.io/jqlang/jq:latest)
  PHP_COMPOSE_SERVICE        Same as -s
  SECRET_SOURCE_METHOD       Same as -m
  SYMFONY_DECRYPTION_SECRET  Satisfies the decryption key check below if set
  SKIP_DECRYPTION_KEY_CHECK  Set to skip the decryption key check below

Secret source methods:
  table             Parses `secrets:list --reveal`'s console table. Default:
                     no file writes, and it refuses to continue (rather
                     than produce corrupted data) if a secret's value can't
                     be parsed reliably -- e.g. contains an embedded
                     newline, which is the only case decrypt-to-local
                     handles that this doesn't.
  decrypt-to-local  Uses `secrets:decrypt-to-local`, a stable/documented
                     Symfony file format. Handles any secret value safely,
                     including ones with embedded newlines, but requires
                     write access to the project directory and briefly
                     mutates .env.{env}.local (restored automatically,
                     even on failure).

Neither the access token nor a secret's value ever appears in this host's
own process listing (`ps`): the token is passed via `docker run --env-file`,
and a secret's value is piped over stdin into BWS_SHELL_DOCKER_IMAGE (see
above), which reads it and execs `bws` with it internally. bws itself has
no stdin/file-based way to receive the value (only a CLI argument), so it
still appears briefly in that specific containerized `bws` process's own
argv while it runs -- that residual exposure is inherent to bws's current
interface and can't be avoided from the outside.
EOF
}

err() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || err "required command \"$1\" not found in PATH."
}

BORDER_RE='^[[:space:]]*-+([[:space:]]+-+)*[[:space:]]*$'

trim() {
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

table_top_border() {
    grep -E "$BORDER_RE" | head -n 1 || true
}

# Data rows sit strictly between the 2nd and 3rd border line (top border,
# header, border-after-header, data rows..., bottom border).
table_data_rows() {
    awk -v re="$BORDER_RE" '
        $0 ~ re { borders++; next }
        borders == 2 { print }
    '
}

# Computes 1-indexed "start end" character ranges for each run of dashes in
# a table border line, so column boundaries are derived from the ACTUAL
# output of this run rather than assumed from a fixed layout.
column_ranges() {
    awk -v border="$1" 'BEGIN {
        n = length(border); incol = 0
        for (i = 1; i <= n; i++) {
            c = substr(border, i, 1)
            if (c == "-") { if (!incol) { start = i; incol = 1 } }
            else if (incol) { print start, i - 1; incol = 0 }
        }
        if (incol) print start, n
    }'
}

# Reads lines from stdin into the named array variable (avoids mapfile,
# which isn't available on bash 3.2).
read_lines_into() {
    local __var=$1 __line
    eval "$__var=()"
    while IFS= read -r __line; do
        eval "$__var+=(\"\$__line\")"
    done
}

# Reads base64(key)/base64(value) pairs, one component per line, from stdin
# into two named parallel array variables. Used to turn one jq pass over a
# JSON object into in-memory lookups, instead of spawning a fresh jq
# container per lookup. Base64 rather than a raw delimiter: it can never
# contain a newline or any character meaningful to `read`, so it's safe
# even for values containing embedded newlines (a NUL delimiter would also
# work in principle, but no shell variable/argv can actually hold a literal
# NUL byte, which rules it out here).
read_kv_pairs_into() {
    local __names_var=$1 __values_var=$2 __k __v
    eval "$__names_var=()"
    eval "$__values_var=()"
    while IFS= read -r __k && IFS= read -r __v; do
        __k=$(printf '%s' "$__k" | base64 -d)
        __v=$(printf '%s' "$__v" | base64 -d)
        eval "$__names_var+=(\"\$__k\")"
        eval "$__values_var+=(\"\$__v\")"
    done
}

SUBCOMMAND="sync"
if [[ $# -gt 0 && "$1" != -* ]]; then
    case "$1" in
        sync|print-ansible-vars) SUBCOMMAND=$1; shift ;;
        *) err "unknown subcommand \"$1\" (expected \"sync\" or \"print-ansible-vars\")." ;;
    esac
fi

OPT_ENV=""
OPT_PROJECT_ID=""
OPT_METHOD="${SECRET_SOURCE_METHOD:-table}"
OPT_COMPOSE_SERVICE="${PHP_COMPOSE_SERVICE:-php}"
ASSUME_YES=0

if [[ "$SUBCOMMAND" == "print-ansible-vars" ]]; then
    while getopts 'p:h' opt; do
        case "$opt" in
            p) OPT_PROJECT_ID=$OPTARG ;;
            h) usage; exit 0 ;;
            *) usage >&2; exit 1 ;;
        esac
    done
else
    while getopts 'e:p:m:s:yh' opt; do
        case "$opt" in
            e) OPT_ENV=$OPTARG ;;
            p) OPT_PROJECT_ID=$OPTARG ;;
            m) OPT_METHOD=$OPTARG ;;
            s) OPT_COMPOSE_SERVICE=$OPTARG ;;
            y) ASSUME_YES=1 ;;
            h) usage; exit 0 ;;
            *) usage >&2; exit 1 ;;
        esac
    done
fi
shift $((OPTIND - 1))

require_cmd docker

if [[ -z "${BWS_ACCESS_TOKEN:-}" ]]; then
    [[ -t 0 ]] || err "BWS_ACCESS_TOKEN is not set and stdin is not a tty."
    printf 'Bitwarden Secrets Manager access token (BWS_ACCESS_TOKEN): ' >&2
    read -rs BWS_ACCESS_TOKEN
    printf '\n' >&2
fi
[[ -n "$BWS_ACCESS_TOKEN" ]] || err "BWS_ACCESS_TOKEN cannot be empty."

BWS_SERVER_URL="${BWS_SERVER_URL:-https://vault.bitwarden.eu}"
BWS_DOCKER_IMAGE="${BWS_DOCKER_IMAGE:-ghcr.io/bitwarden/bws:latest}"
BWS_SHELL_DOCKER_IMAGE="${BWS_SHELL_DOCKER_IMAGE:-lephare/ansible:latest}"
JQ_DOCKER_IMAGE="${JQ_DOCKER_IMAGE:-ghcr.io/jqlang/jq:latest}"

# --- cleanup: always remove the token file and restore/remove any local
# secrets file we touched, no matter how the script exits. ---
LOCAL_ENV_FILE=""
BACKUP_FILE=""
FILE_EXISTED_BEFORE=0
BWS_TOKEN_FILE=""

cleanup() {
    trap - EXIT INT TERM HUP
    [[ -n "$BWS_TOKEN_FILE" && -f "$BWS_TOKEN_FILE" ]] && rm -f "$BWS_TOKEN_FILE"
    if [[ -n "$BACKUP_FILE" && -f "$BACKUP_FILE" ]]; then
        mv -f "$BACKUP_FILE" "$LOCAL_ENV_FILE"
    elif [[ "$FILE_EXISTED_BEFORE" -eq 0 && -n "$LOCAL_ENV_FILE" && -f "$LOCAL_ENV_FILE" ]]; then
        rm -f "$LOCAL_ENV_FILE"
    fi
}
trap cleanup EXIT INT TERM HUP

# BWS_ACCESS_TOKEN is passed to containers via --env-file rather than -e:
# `docker run -e KEY=VALUE` puts VALUE in the docker CLI's own argv, which is
# visible to any local user via `ps` for as long as that command runs --
# --env-file only exposes the (non-sensitive) file path. Written under
# /dev/shm (tmpfs) when available so the token is never written to persistent
# disk, even briefly.
if [[ -d /dev/shm && -w /dev/shm ]]; then
    BWS_TOKEN_FILE=$(mktemp /dev/shm/bws-token.XXXXXX)
else
    BWS_TOKEN_FILE=$(mktemp)
fi
chmod 600 "$BWS_TOKEN_FILE"
printf 'BWS_ACCESS_TOKEN=%s\n' "$BWS_ACCESS_TOKEN" > "$BWS_TOKEN_FILE"

bws() {
    docker run --rm -i \
        --env-file "$BWS_TOKEN_FILE" \
        "$BWS_DOCKER_IMAGE" \
        --server-url "$BWS_SERVER_URL" --output json "$@"
}

# bws has no stdin/file-based way to receive a secret's value (only a CLI
# argument), and its published image ships no shell to bridge stdin into
# that argument internally. BWS_SHELL_DOCKER_IMAGE must be an image with
# both a shell and the bws binary, so the value is piped over stdin here
# and only becomes a CLI argument inside the container, right at the point
# bws itself receives it -- never in this host's own docker run argv.
# `v=$(cat)` rather than `read -r -d ''`: the latter is a bash/ksh
# extension that dash's `read` (e.g. Debian/Ubuntu-based images) rejects
# outright. `cat` + command substitution is POSIX-portable and still
# preserves embedded newlines in the value -- the one known gap is a
# value that itself ends in a trailing newline, which command substitution
# strips (same as any `$(...)` capture).
bws_secret_create() {
    local name=$1 project_id=$2 value=$3
    printf '%s' "$value" | docker run --rm -i \
        --env-file "$BWS_TOKEN_FILE" \
        "$BWS_SHELL_DOCKER_IMAGE" \
        sh -c 'v=$(cat); exec bws --server-url "$1" --output json secret create "$2" "$v" "$3"' \
        _ "$BWS_SERVER_URL" "$name" "$project_id"
}

bws_secret_edit() {
    local secret_id=$1 value=$2
    printf '%s' "$value" | docker run --rm -i \
        --env-file "$BWS_TOKEN_FILE" \
        "$BWS_SHELL_DOCKER_IMAGE" \
        sh -c 'v=$(cat); exec bws --server-url "$1" --output json secret edit "$2" --value "$v"' \
        _ "$BWS_SERVER_URL" "$secret_id"
}

sf() {
    docker compose run --rm --no-tty \
        "$OPT_COMPOSE_SERVICE" php bin/console "$@" --env="$SYMFONY_ENV"
}

jq() {
    docker run --rm -i "$JQ_DOCKER_IMAGE" "$@"
}

# --- resolve the Bitwarden project id (shared by both subcommands) ---
resolve_bws_project_id() {
    BWS_PROJECT_ID="$OPT_PROJECT_ID"
    if [[ -n "$BWS_PROJECT_ID" ]]; then
        bws project get "$BWS_PROJECT_ID" >/dev/null 2>&1 \
            || err "Bitwarden project \"$BWS_PROJECT_ID\" not found (or access token lacks access)."
        return
    fi

    [[ -t 0 ]] || err "no BWS project id given (-p) and stdin is not a tty."

    local projects_json project_count choice project_name
    projects_json=$(bws project list)
    project_count=$(jq 'length' <<<"$projects_json")

    if [[ "$project_count" -gt 0 ]]; then
        printf 'Existing Bitwarden Secrets Manager projects:\n' >&2
        jq -r 'to_entries[] | "  \(.key + 1)) \(.value.name)  [\(.value.id)]"' <<<"$projects_json" >&2
    fi
    printf '  n) create a new project\n' >&2
    printf 'Choice: ' >&2
    read -r choice

    if [[ "$choice" == "n" || "$choice" == "N" ]]; then
        printf 'New project name: ' >&2
        read -r project_name
        [[ -n "$project_name" ]] || err "project name cannot be empty."
        BWS_PROJECT_ID=$(bws project create "$project_name" | jq -r '.id')
        printf 'Created project "%s" (%s).\n' "$project_name" "$BWS_PROJECT_ID" >&2
    else
        [[ "$choice" =~ ^[0-9]+$ ]] || err "invalid choice."
        BWS_PROJECT_ID=$(jq -r --argjson i "$((choice - 1))" '.[$i].id // empty' <<<"$projects_json")
        [[ -n "$BWS_PROJECT_ID" ]] || err "invalid choice."
    fi
}

# Prints, on stdout, the lephare_bitwarden_secrets Ansible mapping for every
# secret currently in $1 (a Bitwarden project id). Everything else this
# writes goes to stderr, so stdout stays a clean, pasteable YAML snippet.
print_ansible_vars_mapping() {
    local project_id=$1 secrets_json api_url identity_url count

    secrets_json=$(bws secret list "$project_id")
    count=$(jq 'length' <<<"$secrets_json")
    if [[ "$count" -eq 0 ]]; then
        printf 'lephare_bitwarden_secrets: {}\n'
        return
    fi

    api_url="${BWS_SERVER_URL}/api"
    identity_url="${BWS_IDENTITY_URL:-${BWS_SERVER_URL/vault./identity.}}"
    if [[ -z "${BWS_IDENTITY_URL:-}" && "$identity_url" == "$BWS_SERVER_URL" ]]; then
        printf 'Warning: could not derive an identity URL from BWS_SERVER_URL ("%s"); defaulting identity_url to the same value -- set BWS_IDENTITY_URL to override.\n' "$BWS_SERVER_URL" >&2
    fi

    # \u0027 is a jq/JSON escape for a literal single quote, used instead of
    # writing one directly so this filter can stay inside a single-quoted
    # bash string without prematurely closing it.
    jq -r --arg base "$BWS_SERVER_URL" --arg api "$api_url" --arg identity "$identity_url" '
        "lephare_bitwarden_secrets:",
        (sort_by(.key | ascii_downcase)[] |
            "  \(.key): \"{{ lookup(\u0027bitwarden.secrets.lookup\u0027, \u0027\(.id)\u0027, base_url=\u0027\($base)\u0027, api_url=\u0027\($api)\u0027, identity_url=\u0027\($identity)\u0027) }}\"")
    ' <<<"$secrets_json"
}

run_sync() {
    case "$OPT_METHOD" in
        decrypt-to-local|table) : ;;
        *) err "invalid -m value \"$OPT_METHOD\" (expected \"decrypt-to-local\" or \"table\")." ;;
    esac

    docker compose version >/dev/null 2>&1 || err "the \"docker compose\" plugin is required but not available."

    SYMFONY_ENV="$OPT_ENV"
    if [[ -z "$SYMFONY_ENV" ]]; then
        [[ -t 0 ]] || err "no Symfony environment given (-e) and stdin is not a tty."
        printf 'Symfony environment to export (e.g. prod, staging): ' >&2
        read -r SYMFONY_ENV
    fi
    [[ -n "$SYMFONY_ENV" ]] || err "Symfony environment cannot be empty."

    # Symfony's default vault_directory convention is
    # config/secrets/{env}/{env}.decrypt.private.php (verified against the
    # framework-bundle 8.1 source). A project can override vault_directory, or
    # supply the key via SYMFONY_DECRYPTION_SECRET instead of a file -- set
    # SKIP_DECRYPTION_KEY_CHECK=1 to bypass this check for such projects.
    if [[ -z "${SKIP_DECRYPTION_KEY_CHECK:-}" ]]; then
        DECRYPTION_KEY_FILE="config/secrets/${SYMFONY_ENV}/${SYMFONY_ENV}.decrypt.private.php"
        [[ -f "$DECRYPTION_KEY_FILE" || -n "${SYMFONY_DECRYPTION_SECRET:-}" ]] \
            || err "no decryption key found for the \"$SYMFONY_ENV\" environment: expected \"$DECRYPTION_KEY_FILE\" or SYMFONY_DECRYPTION_SECRET to be set. If this project uses a non-default vault_directory or supplies the key another way inside its \"$OPT_COMPOSE_SERVICE\" compose service, set SKIP_DECRYPTION_KEY_CHECK=1 to bypass this check."
    fi

    resolve_bws_project_id

    # --- extract (name, value) pairs for $SYMFONY_ENV ---
    SECRET_NAMES=()
    SECRET_VALUES=()   # only populated by extract_via_table

    case "$OPT_METHOD" in
        decrypt-to-local) extract_via_decrypt_to_local ;;
        *) extract_via_table ;;
    esac

    # --- sync each secret into the Bitwarden project ---
    EXISTING_JSON=$(bws secret list "$BWS_PROJECT_ID")
    # One jq pass here instead of one per secret in get_existing_secret_id (a
    # fresh jq container per lookup, times every secret, was purely wasted
    # container-spawn overhead for keys already available locally).
    EXISTING_NAMES=()
    EXISTING_IDS=()
    read_kv_pairs_into EXISTING_NAMES EXISTING_IDS < <(
        jq -r '.[] | "\(.key|@base64)\n\(.id|@base64)"' <<<"$EXISTING_JSON"
    )
    CREATED_COUNT=0
    UPDATED_COUNT=0
    SKIPPED_COUNT=0
    FAILED_COUNT=0

    for idx in "${!SECRET_NAMES[@]}"; do
        name="${SECRET_NAMES[$idx]}"
        [[ -z "$name" ]] && continue
        if [[ "$OPT_METHOD" == "decrypt-to-local" ]]; then
            value=$(get_secret_value_decrypt_to_local "$name")
        else
            value="${SECRET_VALUES[$idx]}"
        fi
        process_secret "$name" "$value"
    done

    printf '\nDone: %d created, %d updated, %d skipped, %d failed.\n' "$CREATED_COUNT" "$UPDATED_COUNT" "$SKIPPED_COUNT" "$FAILED_COUNT"

    printf '\nAnsible variables mapping for project %s:\n' "$BWS_PROJECT_ID" >&2
    print_ansible_vars_mapping "$BWS_PROJECT_ID"

    [[ "$FAILED_COUNT" -eq 0 ]] || exit 1
}

run_print_ansible_vars() {
    resolve_bws_project_id
    print_ansible_vars_mapping "$BWS_PROJECT_ID"
}

# Prints the canonical list of vault secret NAMES (one per line) from a
# plain `secrets:list` (not --reveal). Shared by both extraction methods:
# decrypt-to-local uses it instead of scanning .env.{env}.local for any
# NAME=... looking line, since that file can also hold arbitrary
# local-only overrides a developer added by hand (e.g.
# EMAIL_REDIRECT_RECIPIENTS) that were never part of the vault; table uses
# it as the cross-check against what it parsed from --reveal's table.
get_canonical_secret_names() {
    local names_output names_border names_ranges=() names_only_start names_only_end row
    names_output=$(sf secrets:list)
    names_border=$(table_top_border <<<"$names_output")
    [[ -n "$names_border" ]] \
        || err "could not locate a table border line in secrets:list output."

    read_lines_into names_ranges < <(column_ranges "$names_border")
    [[ "${#names_ranges[@]}" -ge 1 ]] \
        || err "could not determine table column layout from secrets:list output."
    read -r names_only_start names_only_end <<<"${names_ranges[0]}"

    while IFS= read -r row; do
        [[ -z "$row" ]] && continue
        printf '%s\n' "$(trim <<<"${row:names_only_start-1:names_only_end-names_only_start+1}")"
    done < <(table_data_rows <<<"$names_output")
}

extract_via_decrypt_to_local() {
    LOCAL_ENV_FILE=".env.${SYMFONY_ENV}.local"

    if [[ -f "$LOCAL_ENV_FILE" ]]; then
        FILE_EXISTED_BEFORE=1
        BACKUP_FILE=$(mktemp "${LOCAL_ENV_FILE}.bak.XXXXXX")
        cp -p -- "$LOCAL_ENV_FILE" "$BACKUP_FILE"
        # Removed (not just left in place) before decrypting: secrets:decrypt-to-local
        # does an in-place regex replace against any pre-existing line for a
        # name, rather than a clean rewrite. Against a stale pre-existing
        # value (e.g. from before a secret was last rotated) that replace can
        # mangle the result (verified: it spliced a fragment of an old value
        # into the new one for a real secret in this project). Deleting
        # first forces every entry through the plain "append" path instead.
        # The backup above still restores the original on exit regardless.
        rm -f -- "$LOCAL_ENV_FILE"
    fi

    # No byte-diff check here: `set -e` already aborts if this command itself
    # fails (e.g. missing decryption key), and re-running with unchanged
    # secret values legitimately produces byte-identical output -- diffing
    # against that would be a false positive, not a real failure signal.
    sf secrets:decrypt-to-local --force >&2

    [[ -f "$LOCAL_ENV_FILE" ]] \
        || err "\"$LOCAL_ENV_FILE\" was not created by secrets:decrypt-to-local -- check the Symfony environment (-e) and that a decryption key is available."

    read_lines_into SECRET_NAMES < <(get_canonical_secret_names)

    # Parse .env.{env}.local with Symfony's own Dotenv component rather than
    # bash dot-sourcing it: that file can hold arbitrary hand-added entries
    # using characters bash would try to interpret as code (e.g. a value
    # containing a literal "$2", which bash expands as a positional
    # parameter and aborts on under `set -u`). Parsed once here, not once
    # per secret, since it needs its own container invocation.
    local decrypted_values_json
    decrypted_values_json=$(docker compose run --rm --no-tty "$OPT_COMPOSE_SERVICE" php -r '
        require "vendor/autoload.php";
        $vars = (new Symfony\Component\Dotenv\Dotenv())->parse(file_get_contents($argv[1]));
        fwrite(STDOUT, json_encode($vars));
    ' -- "$LOCAL_ENV_FILE")

    # One jq pass here instead of one per secret in get_secret_value_decrypt_to_local
    # (a fresh jq container per lookup, times every secret, was purely wasted
    # container-spawn overhead for keys already available locally).
    read_kv_pairs_into DECRYPTED_NAMES DECRYPTED_VALUES_ARR < <(
        jq -r 'to_entries[] | "\(.key|@base64)\n\(.value|@base64)"' <<<"$decrypted_values_json"
    )
}

get_secret_value_decrypt_to_local() {
    local name=$1 i
    for i in "${!DECRYPTED_NAMES[@]}"; do
        if [[ "${DECRYPTED_NAMES[$i]}" == "$name" ]]; then
            printf '%s' "${DECRYPTED_VALUES_ARR[$i]}"
            return
        fi
    done
}

extract_via_table() {
    local reveal_output reveal_border reveal_ranges=()
    local name_start name_end value_start value_end
    local row name value canonical_names=()

    reveal_output=$(sf secrets:list --reveal)

    reveal_border=$(table_top_border <<<"$reveal_output")
    [[ -n "$reveal_border" ]] \
        || err "could not locate a table border line in secrets:list --reveal output."

    read_lines_into reveal_ranges < <(column_ranges "$reveal_border")
    [[ "${#reveal_ranges[@]}" -ge 2 ]] \
        || err "could not determine table column layout from secrets:list --reveal output."

    read -r name_start name_end <<<"${reveal_ranges[0]}"
    read -r value_start value_end <<<"${reveal_ranges[1]}"

    while IFS= read -r row; do
        [[ -z "$row" ]] && continue
        name=$(trim <<<"${row:name_start-1:name_end-name_start+1}")
        value=$(trim <<<"${row:value_start-1:value_end-value_start+1}")
        if [[ "$value" == \"*\" ]]; then
            value=${value#\"}
            value=${value%\"}
        fi
        SECRET_NAMES+=("$name")
        SECRET_VALUES+=("$value")
    done < <(table_data_rows <<<"$reveal_output")

    read_lines_into canonical_names < <(get_canonical_secret_names)

    [[ "$(printf '%s\n' "${SECRET_NAMES[@]-}")" == "$(printf '%s\n' "${canonical_names[@]-}")" ]] \
        || err "could not reliably parse \"secrets:list --reveal\" output (rows did not line up with a plain \"secrets:list\" -- possibly a multi-line secret value). Re-run with -m decrypt-to-local instead."
}

get_existing_secret_id() {
    local name=$1 i
    for i in "${!EXISTING_NAMES[@]}"; do
        if [[ "${EXISTING_NAMES[$i]}" == "$name" ]]; then
            printf '%s' "${EXISTING_IDS[$i]}"
            return
        fi
    done
}

process_secret() {
    local name=$1 value=$2 existing_id answer

    if [[ -z "$value" ]]; then
        printf 'Skipped "%s": empty value (Bitwarden does not allow empty secrets).\n' "$name" >&2
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        return
    fi

    existing_id=$(get_existing_secret_id "$name")

    if [[ -n "$existing_id" ]]; then
        if [[ "$ASSUME_YES" -eq 0 ]]; then
            if [[ ! -t 0 ]]; then
                printf 'Secret "%s" already exists -- skipping (stdin not a tty, use -y to overwrite non-interactively).\n' "$name" >&2
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                return
            fi
            printf 'Secret "%s" already exists in the project. Overwrite? [y/N] ' "$name" >&2
            read -r answer
            if [[ ! "$answer" =~ ^[Yy] ]]; then
                printf 'Skipped "%s".\n' "$name" >&2
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                return
            fi
        fi
        # A per-secret bws failure (e.g. a transient network/API error)
        # shouldn't abort the whole batch -- report it and keep going.
        if bws_secret_edit "$existing_id" "$value" >/dev/null; then
            printf 'Updated "%s".\n' "$name" >&2
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        else
            printf 'Failed to update "%s".\n' "$name" >&2
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    else
        if bws_secret_create "$name" "$BWS_PROJECT_ID" "$value" >/dev/null; then
            printf 'Created "%s".\n' "$name" >&2
            CREATED_COUNT=$((CREATED_COUNT + 1))
        else
            printf 'Failed to create "%s".\n' "$name" >&2
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    fi
}

case "$SUBCOMMAND" in
    print-ansible-vars) run_print_ansible_vars ;;
    *) run_sync ;;
esac
