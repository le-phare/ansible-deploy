# Permissions

## Conditions

`lephare_permission_set` must be set to `true`

## When

During `lephare_symfony_after_cache_tasks_file`

## Description

If enabled acls will be set for given directories for users and groups specified.

## Variables

| Variable                   | Type     | Default           | Description                       |
| -------------------------- | -------- | ----------------- | --------------------------------- |
| lephare_permission_set     | boolean  | `false`           | Enable permissions support        |
| lephare_permission_paths   | string[] | see [defaults][1] | List of directories to apply to   |
| lephare_permission_users   | string[] | see [defaults][1] | List of users to add to the ACL   |
| lephare_permission_groups  | string[] | see [defaults][1] | List of groups to add to the ACL  |

[1]: ../defaults/main.yml "Default values"
