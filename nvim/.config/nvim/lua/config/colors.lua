vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.expand("~/.config/alacritty-colors.toml"),
  callback = function()
    vim.cmd("syntax reset")
    vim.cmd("redraw!")
  end,
})
