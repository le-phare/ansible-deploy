# lephare.ansible-deploy

Common deploy tasks for projects made at Le Phare.

## Dependencies

- [ansistrano.deploy](https://github.com/ansistrano/deploy)
- [cbrunnkvist/ansistrano-symfony-deploy](https://github.com/cbrunnkvist/ansistrano-symfony-deploy)

## Support matrix

- lephare/ansible:2.0.0 - Ansible 2.17 - Python 3.7 - 3.12 (Target node)
- lephare/ansible:1.12.3 - Ansible 2.15.4 - Python 2.7 or Python 3.5 - 3.11 (Target node)

See [Ansible core support matrix](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix)

## Documentation

* [Workflow overview](docs/workflow.md)
* [Cachetool](docs/cachetool.md)
* Composer:
  * [Private registry](docs/composer/private-registry.md)
  * [Dump Environment](docs/composer/dump-env.md)
* Symfony:
  * [Messenger](docs/symfony/messenger.md)
  * [Secrets](docs/symfony/secrets.md)
* [Permissions](docs/permissions.md)
* [Remove files](docs/remove_files.md)

## Role Variables

`defaults` vars declared in this module can be found here: [defaults/main.yml](defaults/main.yml)

This module overrides defaults vars from `cbrunnkvist.ansistrano-symfony-deploy` and `ansistrano.deploy`.
These overrides can be found here: [vars/main.yml](vars/main.yml)

## Example Playbook

```yaml
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
```

## Optional tasks

### Dump database before composer

**NB: Only works with postgres installed on the app node**

Backup la base de données de la version courante lors du déploiement. Un fichier portant le nom de
la base de données est placer dans la release courante.

Enable task:

```yaml
lephare_dump_database: true
```

Set vars:

```yaml
app_database_name: "{{ db_pull_remote_database_name }}" # required
app_database_login_host: "locahost" # optional
app_database_user: "{{ db_pull_remote_database_user }}" # required
app_database_password: "{{ db_pull_remote_database_password }}" # required
app_database_login_port: 5432 # optional, default 5432
```

## Use with docker

We use a docker image `lephare/ansible` to deploy our projects.

```shell
docker run -it --rm \
    -v $(shell pwd):/app
    -v $(SSH_AUTH_SOCK):/ssh-agent \
    -v $(HOME)/.ssh:/home/ansible/.ssh:ro \
    -e SSH_AUTH_SOCK=/ssh-agent \
    lephare/ansible \
    ansible-playbook \
    -i ansible/production/hosts \
    ansible/deploy.yml
```

## Restore an older PostgreSQL database using db-pull in Docker

**NB: We only support PostgreSQL versions
currently [supported by Alpine Linux](https://pkgs.alpinelinux.org/packages?name=postgresql%3F%3F-client)**

Set vars:

```yaml
db_pull_postgresql_createdb_binary_path: "/usr/libexec/postgresql15/createdb"
db_pull_postgresql_dropdb_binary_path: "/usr/libexec/postgresql15/dropdb"
db_pull_postgresql_pg_restore_binary_path: "/usr/libexec/postgresql15/pg_restore"
```

## Contribute

Clone or fork the repository and make your change in a branch (below is an example for a "fastcgi" branch).

You can test your modification by building your own docker image:

```shell
cd docker
docker build -f Dockerfile.dev .. -t lephare/ansible:fastcgi --no-cache
```

## License

MIT
