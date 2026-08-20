# nvim-minimal

Minimal Neovim 0.12 config, single `init.lua`, managed via `vim.pack`.

    NVIM_APPNAME=nvim-minimal nvim

**Requirements:**
- A [Nerd Font](https://www.nerdfonts.com/) installed and set as your
  terminal font — used for file icons and completion kind icons.
- LSP servers and formatters are **not** auto-installed (no mason) —
  install them yourself, e.g.:
  `brew install lua-language-server rust-analyzer stylua`
  `npm i -g typescript-language-server vscode-langservers-extracted vtsls yaml-language-server prettier`
