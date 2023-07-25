# Cachetool

## Conditions

`lephare_cachetool_enable` must be set to  `true`.

## When

During `lephare_after_symlink_tasks_file`

## Description

Execute [cachetool](https://github.com/gordalina/cachetool) to reset opcache and apc cache after new release has been activated.

Generates a `.cachetool.yaml` to allow simpler command line usage.

## Variables

| Variable                        | Type    | Default                                       | Description                      |
|---------------------------------|---------|-----------------------------------------------|----------------------------------|
| lephare_cachetool_adapter       | string  | `web`                                         | web or fastcgi or cli            |
| lephare_cachetool_fastcgi       | string  | `127.0.0.1:9000`                              | only if adatper is fastcgi       |
| lephare_cachetool_enable        | boolean | `true`                                        | Enable cachetool                 |
| lephare_cachetool_path          | string  | `"{{ ansistrano_deploy_to }}/cachetool.phar"` | Path of the cachetool executable |
| lephare_cachetool_self_update   | boolean | `true`                                        | Allows cachetool to self-update  |
| lephare_cachetool_stat_clear    | boolean | `true`                                        | Clear filesystem stats           |
| lephare_cachetool_opcache_reset | boolean | `true`                                        | Clear opcache                    |
| lephare_cachetool_apcu_clear    | boolean | `true`                                        | Clear APCu cache                 |
| lephare_cachetool_scheme        | string  | `https`                                       | Use HTTP or HTTPS                |
| lephare_cachetool_options       | string  | `""`                                          | Arbitrary option to use          |
| lephare_cachetool_retries       | integer | `10`                                          | Number of retries                |
| lephare_cachetool_delay         | integer | `15`                                          | Delay between retries            |


## Tips

### Speed up cache invalidation

The default cache adapter is `web`. With this configuration, cachetool create a temporary PHP script file and calls it
through the web interface.

The process goes through the full stack: name resolution, TLS, web server, FPM etc . depending on `lephare_cachetool_scheme`.

This call may fail several times until it reaches the `lephare_cachetool_retries` (default 10) limit,
with each retry occurring after `lephare_cachetool_delay` seconds (default 15), which may lead to a 404 error.

By choosing `fastcgi` adapter, cachetool interacts directly with FPM server through the FastCGI protocol.
Unless the PHP setting `opcache.memory_consumption` is insufficient for your codebase, you won't encounter
failure, retries or delays.

**NB**: this adapter is also useful when you have more than 1 server for an app.
For example, if you have two servers `foo` and `bar` behind `https://www.acme.com` and you use `web` adapter,
cachetool will only clear caches on one server behind your load balancer depending on its strategy.
However, using the fastcgi adapter ensures that caches are cleared on both `foo` and `bar` servers.
