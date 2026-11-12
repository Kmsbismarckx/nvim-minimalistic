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
