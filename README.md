# lephare.ansible-deploy

Common deploy tasks for projects made at Le Phare.

## Dependencies

  - [ansistrano.deploy](https://github.com/ansistrano/deploy)
  - [cbrunnkvist/ansistrano-symfony-deploy](https://github.com/cbrunnkvist/ansistrano-symfony-deploy)

## Documentation

* [Workflow overview](docs/workflow.md)
* Composer:
  * [Private registry](docs/composer/private-registry.md)

## Role Variables

The defaults vars declared in this module:

    lephare_default_git_branch: master

    lephare_document_root_path: "{{ ansistrano_deploy_to }}/current/web"

    lephare_assets_publish: true
    lephare_assets_build_path: "../web/compiled/"
    lephare_assets_web_path: "compiled/"

    lephare_cachetool_enable: true
    lephare_cachetool_path: "{{ ansistrano_deploy_to }}/cachetool.phar"
    lephare_cachetool_self_update: true
    lephare_cachetool_stat_clear: true
    lephare_cachetool_opcache_reset: true
    lephare_cachetool_apcu_clear: true
    lephare_cachetool_scheme: https

    lephare_rollbar_notify: true
    lephare_rollbar_environment: production

    lephare_sentry_notify: false
    lephare_sentry_organization: le-phare
    lephare_sentry_environment: production

    lephare_slack_notify: false
    lephare_slack_notify_username: Hubert
    lephare_slack_notify_channel: "#general"

    lephare_crontab_install: false
    lephare_crontab_path: "{{ ansistrano_release_path.stdout }}/app/Resources/crontab"

    lephare_prevent_robots_indexation: false

    lephare_http_basic_secure: false
    lephare_http_basic_whitelist_referer: []
    lephare_http_basic_whitelist_ip: []

    lephare_run_assetic_dump: false
    lephare_run_assets_install: true
    lephare_run_cache_clear_and_warmup: true
    lephare_run_doctrine_migrations: true
    lephare_console_path: bin/console

    lephare_cloudfront_invalidate: false
    lephare_cloudfront_path: [ '/*' ]

    lephare_install_adminer: false
    lephare_install_adminer_path: "{{ lephare_document_root_path }}"

    lephare_permission_set: false
    lephare_permission_paths: [ "{{ ansistrano_release_path.stdout }}/var/cache", "{{ ansistrano_shared_path }}/var/logs" ]
    lephare_permission_users: [ "www-data", "{{ ansible_user }}" ]

Additionnaly, this module change some defaults vars from `cbrunnkvist.ansistrano-symfony-deploy` and `ansistrano.deploy`

    ansistrano_after_symlink_tasks_file: "../../lephare.ansible-deploy/config/after_symlink.yml"
    ansistrano_before_symlink_tasks_file: "../../lephare.ansible-deploy/config/before_symlink.yml"
    ansistrano_git_branch: "{{ lookup('env','CI_BUILD_REF') | default(lephare_default_git_branch, true) }}"
    ansistrano_deploy_via: git
    ansistrano_allow_anonymous_stats: no
    ansistrano_keep_releases: 3

    symfony_run_assetic_dump: "{{ lephare_run_assetic_dump }}"
    symfony_run_assets_install: "{{ lephare_run_assets_install }}"
    symfony_run_cache_clear_and_warmup: "{{ lephare_run_cache_clear_and_warmup }}"
    symfony_run_doctrine_migrations: "{{ lephare_run_doctrine_migrations }}"
    symfony_console_path: "{{ lephare_console_path }}"

## Example Playbook

    ---
    - name: Deploy app
      hosts: app
      roles:
        - lephare.ansible-deploy
      vars:
        lephare_rollbar_token: <token>
        ansistrano_git_repo: git@gitlab.com:foo/bar.git
        ansistrano_shared_paths:
          - var/logs
          - var/sessions
          - var/http_cache
        ansistrano_shared_files:
          - app/config/parameters.yml

## Optional tasks

### Dump database before composer

**NB: Ony works with postgres installed on the app node**

Backup la base de données de la version courante lors du déploiement. Un fichier portant le nom de
la base de données est placer dans la release courante.

Enable task:
```yaml
lephare_dump_database: true
```

Set vars:
```yaml
app_database_name: "{{ db_pull_remote_database_name }}" # required
app_database_login_host:  "locahost" # optional
app_database_user: "{{ db_pull_remote_database_user }}" # required
app_database_password: "{{ db_pull_remote_database_password }}" # required
app_database_login_port: 5432 # optional, default 5432
```

## Use with docker

We use a docker image `lephare/ansible` to deploy our projects.

    docker run -it --rm \
        -v $(shell pwd):/app
        -v $(SSH_AUTH_SOCK):/ssh-agent \
        -v $(HOME)/.ssh:/home/ansible/.ssh:ro \
        -e SSH_AUTH_SOCK=/ssh-agent \
        lephare/ansible \
        ansible-playbook \
        -i ansible/production/hosts \
        ansible/deploy.yml

## Contribute

Clone or fork the repository and make your change in a branch.

You can test your modification by build your own docker image. You need to edit the `docker/roles.yml` and adjust the repository url and branch name. Then you can build the image with.

    $ docker build -t lephare/ansible ./docker --no-cache

## License
MIT
