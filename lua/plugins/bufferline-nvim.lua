return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({})

    vim.keymap.set("n", "<leader>h", ":BufferLineCyclePrev<CR>", opts)
    vim.keymap.set("n", "<leader>l", ":BufferLineCycleNext<CR>", opts)
    vim.keymap.set("n", "<leader>H", ":BufferLineMovePrev<CR>", opts)
    vim.keymap.set("n", "<leader>L", ":BufferLineMoveNext<CR>", opts)
    vim.keymap.set("n", "<C-q>", ":bdelete<CR>", opts)
  end,
}
