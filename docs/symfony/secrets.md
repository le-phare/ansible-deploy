# Symfony secrets

## Conditions

`symfony_secret_private_key` must be set (in the vault).

## When

During `lephare_symfony_before_composer_tasks_file`

## Description

Creates a `decrypt.private.php` file in the `config/secret` directory allowing to use symfony secrets seamlessly.
