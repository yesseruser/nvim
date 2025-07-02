return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			ensure_installed = {
				"lua",
				"c",
				"cpp",
				"css",
				"html",
				"rust",
				"tsx",
				"typescript",
				"javascript",
				"markdown",
        "svelte",
        "dockerfile",
        "dart",
        "go",
        "php",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
