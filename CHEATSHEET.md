# Neovim cheatsheet — LazyVim + kernel customs

Personal reference. `<leader>` is `<Space>` (LazyVim default).

Discovery: press `<Space>` in normal mode and pause — **which-key** shows all available next keys with descriptions. That replaces 80% of this cheatsheet.

---

## Claude Code

| Key | What it does |
|-----|--------------|
| `<leader>ac` | Toggle Claude pane on the right |
| `<leader>af` | Focus the Claude pane |
| `<leader>ar` | Resume previous session |
| `<leader>aC` | Continue most recent session |
| `<leader>am` | Pick model (Sonnet / Opus / Haiku) |
| `<leader>ab` | Add current buffer as context |
| `<leader>as` | (visual mode) Send selection to Claude |
| `<leader>aA` | Accept proposed diff |
| `<leader>aD` | Reject proposed diff |

Workflow: visual-select code → `<leader>as` → ask Claude → review diff buffer → `<leader>aA` to accept.

---

## LazyVim built-in essentials

| Key | What it does |
|-----|--------------|
| `<leader><space>` | Smart find files (Telescope/Snacks) |
| `<leader>/` | Live grep across project |
| `<leader>,` | Switch buffer |
| `<leader>:` | Command history |
| `<leader>e` | Toggle file explorer (neo-tree) |
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>gg` | LazyGit |
| `<leader>l` | LazyVim plugin manager |
| `<leader>L` | LazyVim about |
| `<leader>x` | Diagnostics (trouble) submenu |
| `<leader>cd` | Diagnostics under cursor |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format buffer |
| `<leader>cl` | LSP info |

Press `<Space>` and pause — **which-key shows everything**.

---

## LSP navigation (clangd for C)

| Key | What it does |
|-----|--------------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References (Telescope) |
| `gI` | Implementations |
| `gy` | Type definition |
| `K`  | Hover documentation |
| `]d` / `[d` | Next / prev diagnostic |
| `]e` / `[e` | Next / prev error |

For clangd to work on the kernel, generate `compile_commands.json` once:

```bash
cd ~/SRC/linux
./scripts/clang-tools/gen_compile_commands.py
```

The `~/SRC/linux/.clangd` file already strips kernel-specific flags clangd can't handle.

---

## Treesitter textobjects (function/scope navigation)

| Key | What it does |
|-----|--------------|
| `]m` / `[m` | Next / prev function start |
| `]M` / `[M` | Next / prev function end |
| `]]` / `[[` | Next / prev class/struct |
| `vaf` / `vif` | Visual around/inside function |
| `vac` / `vic` | Visual around/inside class |
| `vab` / `vib` | Visual around/inside block |

Combine: `daf` deletes a function, `yaf` yanks one. Killer for kernel C with 2000-line files.

---

## Aerial outline panel

| Key | What it does |
|-----|--------------|
| `<leader>cO` | Toggle outline panel on the right |

Inside outline: `j`/`k` to navigate, `<cr>` to jump, `q` to close.

---

## cscope (kernel macro navigation fallback)

When clangd loses you in macros (kernel has thousands), cscope finds the answer:

| Key | What it does |
|-----|--------------|
| `<leader>fs` | Symbol references |
| `<leader>fg` | Definition |
| `<leader>fC` | Callers |
| `<leader>fT` | Text |
| `<leader>fF` | File |
| `<leader>fI` | Includes |

Generate cscope db once: `cscope -bqRk` from `~/SRC/linux`.

---

## DAP debugger (kernel via gdb stub)

LazyVim's DAP extra needs to be enabled first: `:LazyExtras`, find "dap.core", press `<x>`.

| Key | What it does |
|-----|--------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | REPL |
| `<leader>du` | Toggle UI |
| `<leader>dt` | Terminate |

Configured for `arm-linux-gnueabihf-gdb` attaching to `10.40.25.59:1234` (edit `lua/plugins/kernel-and-ai.lua` to change target).

---

## Kernel commands

| Key | What it does |
|-----|--------------|
| `<leader>k`  | checkpatch on current file |
| `<leader>K`  | checkpatch on HEAD commit |
| `<leader>cb` | Compile media drivers |

---

## Search

`/` is mapped to `/\v` (very magic mode). POSIX-style regex by default — `()`, `+`, `?`, `{}` work without escaping.

---

## Useful LazyVim commands

```vim
:Lazy            " plugin manager UI
:Lazy update     " update all plugins
:Lazy sync       " update + clean
:LazyExtras      " browse and toggle pre-built extras
:LazyHealth      " health check
:Mason           " install LSP servers / formatters / linters
:checkhealth     " general nvim health
```

---

## On a new machine

```bash
# Clone YOUR config from GitHub
git clone git@github.com:Balki01/nvim-config.git ~/.config/nvim

# First nvim launch installs all plugins via lazy.nvim
nvim

# Once for the kernel tree: generate clangd index
cd ~/SRC/linux
./scripts/clang-tools/gen_compile_commands.py
```

That's it.
