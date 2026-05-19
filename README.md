# Balki's Neovim config

Personal LazyVim-based configuration tuned for Linux kernel development on
Microchip MPU SoCs (sama7g5, sama5d2, sam9x7).

## Install on a fresh machine

```bash
# Clone
git clone git@github.com:Balki01/nvim-config.git ~/.config/nvim

# Prerequisite (Ubuntu 22.04 or older — older glibc):
# Install a tree-sitter CLI version that doesn't require GLIBC 2.39.
# v0.22.6 is known good on Ubuntu 22.04 (glibc 2.35).
npm install -g tree-sitter-cli@0.22.6

# First nvim launch installs all plugins via lazy.nvim
nvim

# Once for the kernel tree (after a kernel build): generate clangd index
cd ~/SRC/linux
./scripts/clang-tools/gen_compile_commands.py
```

## Layout

```
init.lua                              bootstrap
lua/config/lazy.lua                   LazyVim setup (starter default)
lua/config/options.lua                vim options
lua/config/keymaps.lua                personal keymaps (checkpatch, build)
lua/config/autocmds.lua               personal autocmds (kernel style)
lua/plugins/kernel-and-ai.lua         personal plugins (Claude, aerial,
                                      cscope, treesitter parsers, DAP)
CHEATSHEET.md                         single-page keybinding reference
```

See `CHEATSHEET.md` for keybindings.

## Notes

- LazyVim does the heavy lifting: LSP via Mason, completion, fuzzy finder,
  git integration, treesitter, diagnostics panel.
- `<leader>` is `<Space>`. Press it and pause — which-key shows everything.
- Kernel files under `~/SRC/linux/` auto-switch to hard tabs / 8-wide / 80
  cols and set `makeprg` so `:make` does a cross-compile.
