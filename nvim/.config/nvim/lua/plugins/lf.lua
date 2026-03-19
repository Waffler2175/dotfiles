return {
    "lmburns/lf.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    lazy = false, 
    init = function()
        vim.g.lf_netrw = 1
    end,
    config = function()
        require("lf").setup({
            -- 'tab' is the closest valid way to get a 'new screen' feel
            direction = "tab", 
            
            default_action = "drop",
            escape_quit = true,
            focus_on_open = true,
            mappings = true,
            
            default_file_manager = true,
            disable_netrw_warning = true,
            border = "none", -- Borders don't apply to tab mode anyway
        })

        -- Mapping to open LF
        vim.keymap.set("n", "<M-o>", "<Cmd>Lf<CR>", { desc = "Open LF" })
    end,
}
