lephare.ansible-deploy
======================

Common deploy tasks for projects made at Le Phare

Role Variables
--------------

The defaults vars declared in this module:

    lephare_default_git_branch: master

    lephare_publish_assets: true

    lephare_cachetool_path: "{{ ansistrano_deploy_to }}/cachetool.phar"
    lephare_cachetool_self_update: true
    lephare_cachetool_stat_clear: true
    lephare_cachetool_opcache_reset: true

    lephare_rollbar_notify: true
    lephare_rollbar_environment: production

    lephare_crontab_install: false
    lephare_crontab_path: "{{ ansistrano_release_path.stdout }}/app/Resources/crontab.preprod"

    lephare_prevent_robots_indexation: false

    lephare_http_basic_secure: false
    lephare_http_basic_whitelist_referer: []
    lephare_http_basic_whitelist_ip: []

Additionnaly, this module change some defaults vars from `cbrunnkvist.ansistrano-symfony-deploy` and `ansistrano.deploy`

    ansistrano_git_branch: "{{ lookup('env','CI_BUILD_REF') | default(lephare_default_git_branch, true) }}"
    ansistrano_deploy_via: git
    ansistrano_allow_anonymous_stats: no
    ansistrano_keep_releases: 3
    ansistrano_shared_files:
      - app/config/parameters.yml
    ansistrano_shared_paths:
      - var/logs
      - var/sessions
      - var/exchange
      - var/http_cache
      - web/medias
      - web/compiled


    symfony_run_assetic_dump: false
    symfony_run_assets_install: false
    symfony_run_cache_clear_and_warmup: true
    symfony_run_doctrine_migrations: true
    symfony_console_path: bin/console

Dependencies
------------

  - cbrunnkvist.ansistrano-symfony-deploy
  - ansistrano.deploy

Example Playbook
----------------

    ---
    - name: Deploy app
      hosts: app
      roles:
        - lephare.ansible-deploy
      vars:
        lephare_rollbar_token: d6a7e56171364bf2b0a1e66e1cbb335f
        ansistrano_git_repo: git@gitlab.com:lephare/royer-b2b.git
        ansistrano_shared_paths:
            - var/logs
            - var/sessions
            - var/http_cache
        ansistrano_shared_files:
          - app/config/parameters.yml

License
-------

MIT
