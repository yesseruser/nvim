return {
  {
   "github/copilot.vim",
    config = function()
      -- disable copilot by default
      vim.g.copilot_enabled = false
      vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", {silent=true})
      vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", {silent=true})
      vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", {silent=true})
    end,
  },
}
