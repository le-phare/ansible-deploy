# Composer Dump Environment

## Conditions

`lephare_composer_dump_environment` must be `true`.

## When

During `lephare_symfony_after_composer_tasks_file`

## Description

Dump symfony environment to `.env.local.php` using the `symfony_env` variable.
