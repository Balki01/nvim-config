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
map("n", "<leader>cb", "<cmd>make<cr>",       { desc = "Build (:make)" })
map("n", "<leader>cB", "<cmd>make clean<cr>", { desc = "Build clean" })

-- ── AI inline edit (Cursor-style) using local `claude` CLI ──────────────
-- Visual-select code, press <leader>ai, type instruction, watch the
-- selection get rewritten in place. `u` to undo if not happy.
-- Uses the local CLI auth — no API key needed.
map("v", "<leader>ai", function() require("custom.ai-edit").edit() end,
  { desc = "AI edit selection (claude CLI)" })

-- ── Tags ─────────────────────────────────────────────────────────────────
-- Built-in vim tag commands (work whenever a tags file is present):
--   <C-]>   jump to tag definition
--   <C-t>   jump back from tag stack
--   <C-w>}  preview tag in a split (peek without jumping)
--   :tag X  jump to symbol X
--   :tjump  prompt to choose if multiple matches
--
-- Browse all tags via Telescope fuzzy picker.
map("n", "<leader>st", "<cmd>Telescope tags<cr>",                 { desc = "Tags (Telescope)" })
map("n", "<leader>sT", "<cmd>Telescope current_buffer_tags<cr>",  { desc = "Buffer tags (Telescope)" })

-- ── Kernel: regenerate tags + cscope using the kernel's Makefile ────────
-- The kernel ships its own ctags/cscope targets that produce a much
-- better index than plain `ctags -R` (handles arch-specific code,
-- inline asm, kernel-specific tag kinds).
vim.api.nvim_create_user_command("KernelTags", function()
  local cmd = "cd ~/SRC/linux && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- "
              .. "tags cscope SRCARCH=arm"
  vim.cmd("!" .. cmd)
end, { desc = "Regenerate kernel ctags + cscope databases" })

-- And a key for it
map("n", "<leader>tk", "<cmd>KernelTags<cr>", { desc = "tags: kernel rebuild" })
