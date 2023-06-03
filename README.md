# Typst syntax highlight

[![](https://img.shields.io/badge/license-MIT-brightgreen)](./LICENSE.txt)
[![](https://img.shields.io/badge/Sublime%20Text-4-ff9800)](https://www.sublimetext.com/blog/articles/sublime-text-4)

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/8097890/241095831-5f66d097-bb86-44e6-9014-7237cb9f59e4.png">
    <source media="(prefers-color-scheme: light)" srcset="https://user-images.githubusercontent.com/8097890/241097972-48c03f13-3bc8-4095-8533-28de079599fc.png">
    <img alt="screenshot" src="https://user-images.githubusercontent.com/8097890/241095831-5f66d097-bb86-44e6-9014-7237cb9f59e4.png">
  </picture>
</p>

## Install

- Via Package Control: search for `Typst`.
- Manual: clone this repo into your Sublime `Packages` folder.

## Recipes

### Show auto complete panel without pressing TAB

You can create a [syntax specific settings](https://www.sublimetext.com/docs/settings.html#syntax-specific-settings)
with the config below:

```json
{
  "auto_complete_selector": "text.typst"
}
```

### Build with Makefile

You can create a [build system](https://www.sublimetext.com/docs/build_systems.html)
with the config below:

```json
{
  "cmd": ["make"],
  "selector": "text.typst",
  "file_regex": "┌─ (...*?):([0-9]*):?([0-9]*)",
  "env": { "NO_COLOR": "1" },
  "cancel": { "kill": true }
}
```

## License

MIT @ [hyrious](https://github.com/hyrious)
