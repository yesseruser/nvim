return {
	"nvim-treesitter/nvim-treesitter",
  branch = "main",
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.config")
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
        "luau",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
