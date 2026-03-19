return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.config').setup {
	    highlight = {
	      enable = true,
	   },
	   indent = { enable = true },
	   autotage = {enable = true },
	   ensure_installed = {
	    "lua",
	    "rust",
    	},
	   auto_install=true,
        }
    end

}
