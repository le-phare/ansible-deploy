# Set dotenv

## Condition

`lephare_set_dotenv_variables` must be defined and not empty.

## When

During `ansistrano_symfony_after_composer_tasks_file`

## Description

Set environment variables configured in `lephare_set_dotenv_variables` into `.env.local`.

## Example

```yaml
lephare_set_dotenv_variables:
  VAR_1: "value_1"
  VAR_2: "value_2"
```

Before:

```dotenv
# .env.local
OTHER_VAR: other_value
VAR_1: old_value_1
```

After:

```dotenv
# .env.local
OTHER_VAR: other_value
VAR_1: value_1
VAR_2: value_2
```
