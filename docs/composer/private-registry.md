# Composer Private Registry

## Conditions

`lephare_packagist_com_token` must be set.

## When

During `lephare_symfony_before_composer_tasks_file`

## Description

Creates a `auth.json` file in the `COMPOSER_HOME` directory.

## Known limitations

- Only support `repo.packagist.com` for now.
- Overwrite any existing `auth.json` file.
