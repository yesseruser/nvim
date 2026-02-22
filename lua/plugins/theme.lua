return {
	"RedsXDD/neopywal.nvim",
	name = "neopywal",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		require("neopywal").setup({
			use_palette = "everforest-hard",
		})
		vim.cmd.colorscheme("neopywal")
	end,
}
