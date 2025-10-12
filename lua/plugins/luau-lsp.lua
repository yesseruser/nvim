return {
  "lopi-py/luau-lsp.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local function rojo_project()
      return vim.fs.root(0, function(name)
        return name:match ".+%.project%.json$"
      end)
    end

    require("luau-lsp").setup {
      platform = {
        type = rojo_project() and "roblox" or "standard",
      },
      plugin = {
        enabled = true,
        port = 3667,
      },
      types = {
        roblox_security_level = "PluginSecurity",
      },
      sourcemap = {
        enabled = true,
        autogenerate = true, -- automatic generation when the server is initialized
        rojo_project_file = "default.project.json",
        sourcemap_file = "sourcemap.json",
      },
    }
  end
}
