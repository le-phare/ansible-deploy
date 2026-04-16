# BazingaJsTranslationBundle JS Translation Dump

## Conditions

`lephare_bazinga_js_translation_dump` must be set to `true`

## When

During `lephare_symfony_after_composer_tasks_file`

## Description

Runs the `bazinga:js-translation:dump` Symfony console command to export translations
for use in JavaScript via the [BazingaJsTranslationBundle](https://github.com/willdurand/BazingaJsTranslationBundle).

## Variables

| Variable                                 | Type    | Default | Description                                                                                               |
| ---------------------------------------- | ------- | ------- | --------------------------------------------------------------------------------------------------------- |
| lephare_bazinga_js_translation_dump      | boolean | `false` | Enable the JS translation dump step                                                                       |
| lephare_bazinga_js_translation_dump_args | string  | `""`    | Optional arguments passed to the `bazinga:js-translation:dump` command (e.g. a custom target directory)  |

## Example

```yaml
lephare_bazinga_js_translation_dump: true
lephare_bazinga_js_translation_dump_args: "public/js"
```
