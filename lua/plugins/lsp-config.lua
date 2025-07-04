local lsps = {
  "bashls",
  "clangd",
  "marksman",
  "lua_ls",
  "csharp_ls",
  "cssls",
  "tailwindcss",
  "pyright",
  "lua_ls",
  "eslint",
  "gradle_ls",
  "phpactor"
}

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = lsps,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("lspconfig").rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy"
            }
          },
        },
      })

      for _, lsp in ipairs(lsps) do
        require("lspconfig")[lsp].setup({
          capabilities = capabilities,
        })
      end
      local opts = {}

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
      vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, { desc = "Rename variable or functin" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
    end,
  },
}
