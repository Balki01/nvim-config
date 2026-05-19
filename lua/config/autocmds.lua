-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Linux kernel coding style: hard tabs, 8-wide, 80 cols, colorcolumn at 81.
-- Active for any file under ~/SRC/linux/.
-- Also sets makeprg so :make and <leader>cb run a kernel cross-compile.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("kernel_style", { clear = true }),
  pattern = vim.fn.expand("~") .. "/SRC/linux/*",
  desc = "Linux kernel coding style and build",
  callback = function()
    -- Coding style
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 8
    vim.bo.textwidth = 80
    vim.opt_local.colorcolumn = "81"

    -- Buffer-local makeprg: run kernel build from the kernel root.
    -- :make / <leader>cb uses this. Errors land in quickfix.
    vim.opt_local.makeprg =
      "make -C " .. vim.fn.expand("~") .. "/SRC/linux "
      .. "ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc)"
  end,
})
