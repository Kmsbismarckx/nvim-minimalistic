# nvim-minimal

Minimal Neovim 0.12 config, single `init.lua`, managed via `vim.pack`.

    NVIM_APPNAME=nvim-minimal nvim

**Requirements:**
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your
  terminal font — used for file icons and completion kind icons.
- LSP servers and formatters are **not** auto-installed (no mason) —
  install them yourself, e.g.:
  `brew install lua-language-server rust-analyzer stylua ktlint`
  `npm i -g @vtsls/language-server vscode-langservers-extracted yaml-language-server prettier`

**LSP profiles (per session):**

```sh
NVIM_APPNAME=nvim-minimalistic NVIM_LSP=rust nvim
NVIM_APPNAME=nvim-minimalistic NVIM_LSP=react nvim
```

`rust`: rust-analyzer. `react`: vtsls, ESLint, HTML, CSS and JSON.
`none`: disable LSP. Unset or `all`: enable all configured servers.
Unknown profiles show a warning and disable LSP. Formatters and Treesitter
are independent of the selected profile.

**Keymaps:** `<leader>` is Space; first letter selects a group, second an action.

| Group | Keys |
| --- | --- |
| Files | `ff` find, `fg` grep, `fr` resume picker, `ft` TODOs |
| Buffers | `bb` list, `bd` delete |
| Git | `gd` open diff, `gc` close diff |
| Diagnostics | `dd` project, `db` buffer, `dq` quickfix |
| Code | `ca` action, `cr` rename, `cf` format |
| Symbols | `sd` document, `sw` workspace |
| Toggles | `th` inlay hints |
| Hunks | `hp` preview, `hs` stage, `hr` reset, `hb` blame |

Navigation stays on `gd`, `grr`, `gri`, `grt`, `gD`, `K`, `[d` / `]d`,
`[h` / `]h`, and `-` (parent directory). Press Space to see groups in Which-key.

JS/TS saving and `<leader>cf` run ESLint fix-all through the attached ESLint LSP,
then Prettier. `eslint_d` is not needed. The project needs ESLint and its config;
use the `react` or `all` LSP profile. Only auto-fixable issues are corrected.
