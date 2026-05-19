-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ── Search: very magic mode by default (POSIX-style regex) ──────────────
map("n", "/", [[/\v]], { desc = "search (very magic)" })

-- ── Linux kernel: checkpatch ─────────────────────────────────────────────
map("n", "<leader>k", function()
  vim.cmd("write")
  vim.cmd("!~/SRC/linux/scripts/checkpatch.pl --strict --terse --no-tree -f " .. vim.fn.expand("%"))
end, { desc = "checkpatch on current file" })

map("n", "<leader>K", function()
  vim.cmd("!cd ~/SRC/linux && ./scripts/checkpatch.pl --strict -g HEAD")
end, { desc = "checkpatch on HEAD commit" })

-- ── Generic build via Vim's :make ────────────────────────────────────────
-- Uses the buffer's `makeprg` option. Default is plain `make`. Kernel
-- files override `makeprg` in autocmds.lua to do a cross-compile.
-- Quickfix list opens automatically with errors.
map("n", "<leader>cb", "<cmd>make<cr>",      { desc = "Build (:make)" })
map("n", "<leader>cB", "<cmd>make clean<cr>", { desc = "Build clean" })
