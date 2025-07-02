return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      css = { rgb_fn = true; };
      'javascript';
    }, { mode = "background" })
  end,
}
