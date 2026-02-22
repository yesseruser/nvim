vim.opt.termguicolors = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cs", "java", "python" },
	callback = function()
		vim.opt.shiftwidth = 4
		vim.opt.tabstop = 4
		vim.opt.softtabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "luau" },
	callback = function()
		vim.opt.expandtab = false
		vim.opt.shiftwidth = 4
		vim.opt.tabstop = 4
		vim.opt.softtabstop = 4
	end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.scrolloff = 8

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
