-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ── Linux kernel: checkpatch ─────────────────────────────────────────────
map("n", "<leader>k", function()
  vim.cmd("write")
  vim.cmd("!~/SRC/linux/scripts/checkpatch.pl --strict --terse --no-tree -f " .. vim.fn.expand("%"))
end, { desc = "checkpatch on current file" })

map("n", "<leader>K", function()
  vim.cmd("!cd ~/SRC/linux && ./scripts/checkpatch.pl --strict -g HEAD")
end, { desc = "checkpatch on HEAD commit" })

-- ── Build kernel via build-deploy.sh (no auto-deploy) ────────────────────
map("n", "<leader>cb", function()
  vim.cmd("!cd ~/SRC/linux && make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- drivers/media/platform/microchip/")
end, { desc = "Compile microchip media drivers" })
