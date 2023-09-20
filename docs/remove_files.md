# Remove files

## Condition

`lephare_remove_files` must be set to `true`.

## When

During `lephare_before_symlink_tasks_file`

## Description

If enabled, files present in `lephare_remove_files_paths` will be removed from release. This is useful to ensure some files are not present in production even if they are committed in your repository.

## Variables

| Variable                   | Type     | Default           | Description                       |
| -------------------------- | -------- | ----------------- | --------------------------------- |
| lephare_remove_files     | boolean  | `false`           | Toggles remove files feature        |
| lephare_remove_files_paths   | string[] | `[]` | List of files to remove  |
