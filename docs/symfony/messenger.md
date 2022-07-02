# Symfony messenger

## Conditions

`symfony_messenger_enable` must be set to `true`

## When

During `lephare_symfony_before_doctrine_tasks_file`
And `lephare_after_symlink_tasks_file`

## Description

If enabled messenger will be stopped before doctrine migrations and restarted after
opcache cleanup.

### Queue configuration

The default configuration is the following

```yaml
symfony_messenger_queues:
  - name: default
    time_limit: 7
```

| Key                        | Type   | Description                                           |
| -------------------------- | ------ | ----------------------------------------------------- |
| name                       | string | The name of the messenger queue                       |
| time_limit                 | int    | The time limit in minutes before process is restarted |

Scaling can be achieved by defining the same queue multiple times.

This configuration will schedule to "default" workers and one "failed":

```yaml
symfony_messenger_queues:
  - name: default
    time_limit: 7
  - name: default
    time_limit: 7
  - name: failed
    time_limit: 7
```

You can also group workers queues by setting a space separated list in the name property:

```yaml
symfony_messenger_queues:
  - name: default failed
    time_limit: 7
```

### Strategies

Only one strategy is available for now: crontab.

#### Crontab strategy

Symfony Messenger worker will be setup as one or more crontab jobs depending on the
configuration given in the `symfony_messenger_queues` variable.

## Variables

| Variable                   | Type    | Default                           | Description                                                         |
| -------------------------- | ------- | --------------------------------- | ------------------------------------------------------------------  |
| symfony_messenger_enable   | boolean | `false`                           | Enable symfony messenger                                            |
| symfony_messenger_strategy | string  | `crontab`                         | Strategy used to manager messenger (only crontab supported for now) |
| symfony_messenger_queues   | list    | [see above](#queue-configuration) | Define queues, respawn time...                                      |
