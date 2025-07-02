return {
	"nat-418/boole.nvim",
	config = function()
		require("boole").setup({
			additions = {
				{ "Foo", "Bar", "Baz", "Qux" },
				{ "foo", "bar", "baz", "qux" },
			},
			mappings = {
				increment = "<C-a>",
				decrement = "<C-x>",
			},
		})
	end,
}
