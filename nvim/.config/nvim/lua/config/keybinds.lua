vim.g.mapleader= " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("n", "<leader>fc", function()
    require("lf").start({ dir = vim.fn.stdpath("config") })
end, { desc = "Open Neovim config in lf" })

