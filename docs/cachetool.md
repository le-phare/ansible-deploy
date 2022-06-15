# Cachetool

## Conditions

`lephare_cachetool_enable` must be set to  `true`.

## When

During `lephare_after_symlink_tasks_file`

## Description

Execute [cachetool](https://github.com/gordalina/cachetool) to reset opcache and apc cache after new release as been activated

## Variables

| Variable                        | Type    | Default                                        | Description                      |
| ------------------------------- | ------- | ---------------------------------------------- | -------------------------------- |
| lephare_cachetool_enable        | boolean |  `true`                                        | Enable cachetool                 |
| lephare_cachetool_path          | string  |  `"{{ ansistrano_deploy_to }}/cachetool.phar"` | Path of the cachetool executable |
| lephare_cachetool_self_update   | boolean |  `true`                                        | Allows cachetool to self-update  |
| lephare_cachetool_stat_clear    | boolean |  `true`                                        | Clear filesystem stats           |
| lephare_cachetool_opcache_reset | boolean |  `true`                                        | Clear opcache                    |
| lephare_cachetool_apcu_clear    | boolean |  `true`                                        | Clear APCu cache                 |
| lephare_cachetool_scheme        | string  |  `https`                                       | Use HTTP or HTTPS                |
| lephare_cachetool_options       | string  |  `""`                                          | Arbitrary option to use          |
