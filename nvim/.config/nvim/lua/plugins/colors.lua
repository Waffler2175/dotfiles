return {
    {
        "RRethy/base16-nvim",
        config = function()
            require('colors.matugen').setup()
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            theme = "base16",
        },
    },
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
        config = function()
            require("transparent").setup({})

            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "base16-*",
                callback = function()
                    require("transparent").clear_prefix("")
                    require("lualine").setup({ theme = "base16" })
                end,
            })
        end,
    },
}
