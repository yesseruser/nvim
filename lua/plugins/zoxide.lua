return {
  "nanotee/zoxide.vim",
  dependencies = {
    "junegunn/fzf",
    "junegunn/fzf.vim",
  },
  config = function()
    vim.keymap.set("n", "<leader>z", ":Zi<CR>", { silent = true })
  end,
}

