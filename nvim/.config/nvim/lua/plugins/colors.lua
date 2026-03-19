return {
    { 
	"RRethy/base16-nvim",
        config = function()
	    require('matugen').setup()
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
	lazy = false, -- Avoid lazy-loading
	config = function()
	    require("transparent").setup({
	    })
	end,
    },

	
}
