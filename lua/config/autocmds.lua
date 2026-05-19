-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Linux kernel coding style: hard tabs, 8-wide, 80 cols, colorcolumn at 81.
-- Active for any file under ~/SRC/linux/ (or */linux/drivers/* / */linux/include/*).
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("kernel_style", { clear = true }),
  pattern = {
    vim.fn.expand("~") .. "/SRC/linux/*",
    "*/linux/drivers/*",
    "*/linux/include/*",
  },
  desc = "Linux kernel coding style: hard tabs, 8-wide, 80 cols",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 8
    vim.bo.textwidth = 80
    vim.opt_local.colorcolumn = "81"
  end,
})
