# nvim-minimalistic

Minimal Neovim 0.12 config, single `init.lua`, managed via `vim.pack`.

## Installation

**Requirements:**
- Neovim 0.12 (checked with 0.12.6), Git, and `ripgrep` for text search.
- Treesitter parser installation: a C compiler, `tree-sitter-cli` 0.26.1+,
  `curl` and `tar`.
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your
  terminal font — used for file icons and completion kind icons.
- LSP servers and formatters are **not** auto-installed (no mason) —
  install them yourself, e.g.:
  `brew install lua-language-server rust-analyzer stylua`
  `npm i -g @vtsls/language-server vscode-langservers-extracted yaml-language-server prettier`
- Rust tooling: `rustfmt` for formatting and Clippy for LSP checks.

Clone the config and launch Neovim:

```sh
git clone https://github.com/Kmsbismarckx/nvim-minimalistic.git ~/.config/nvim-minimalistic
NVIM_APPNAME=nvim-minimalistic nvim
```

Plugins and Treesitter parsers install automatically on first launch.

## Features

- LSP diagnostics, code navigation, rename, code actions and inlay hints.
- Completion and snippets, automatic bracket pairing.
- File, text, symbol and TODO search; editable directory browser with Oil.
- Git diffs, history, hunk staging/reset and inline blame.
- Formatting on save; ESLint fixes followed by Prettier for JS/TS.
- Treesitter highlighting and Markdown rendering.
- Tokyo Night theme and keymap hints via Which-key.

## LSP profiles

Select a profile per session:

```sh
NVIM_APPNAME=nvim-minimalistic NVIM_LSP=rust nvim
NVIM_APPNAME=nvim-minimalistic NVIM_LSP=react nvim
```

`rust`: rust-analyzer. `react`: vtsls, ESLint, HTML, CSS and JSON.
`none`: disable LSP. Unset or `all`: enable all configured servers.
Formatters are independent of the selected profile.

## Keymaps

`<leader>` is Space; first letter selects a group, second an action.

| Group | Keys |
| --- | --- |
| Files | `ff` find, `fg` grep, `fr` resume picker, `ft` TODOs |
| Buffers | `bb` list, `bd` delete |
| Git | `gd` open diff, `gc` close diff, `gh` history, `gH` file history |
| Diagnostics | `dd` project, `db` buffer, `dq` quickfix |
| Code | `ca` action, `cr` rename, `cf` format |
| Symbols | `sd` document, `sw` workspace |
| Toggles | `th` inlay hints, `tm` Markdown rendering |
| Hunks | `hp` preview, `hs` stage, `hr` reset, `hb` blame |

Navigation stays on `gd`, `grr`, `gri`, `grt`, `gD`, `K`, `[d` / `]d`,
`[h` / `]h`, and `-` (parent directory). Press Space to see groups in Which-key.

Formatting runs on save or with `<leader>cf`. JS/TS uses ESLint fix-all
(when attached), then Prettier. Install ESLint and its config in the project;
use the `react` or `all` profile.

More: [Markdown](docs/markdown.md) · [Releases](docs/versioning.md).
