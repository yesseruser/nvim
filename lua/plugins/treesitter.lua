return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	dependencies = { "neovim-treesitter/treesitter-parser-registry" },
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local installed = {
			"lua",
			"c",
			"cpp",
			"css",
			"c_sharp",
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
			"nix",
		}
		require("nvim-treesitter").install(installed)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf) -- highlighting
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- folds
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- indentation
			end,
		})
	end,
}
