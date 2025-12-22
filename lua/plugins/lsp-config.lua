local lsps = {
  "bashls",
  "clangd",
  "marksman",
  "csharp_ls",
  "lua_ls",
  "cssls",
  "tailwindcss",
  "basedpyright",
  "eslint",
  "gradle_ls",
  "phpactor",
  "luau_lsp"
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
        automatic_enable = {
          exclude = { "luau_lsp" },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config["rust_analyzer"] = {
        settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              enable = false,
            },
          },
        },
      }

      for _, lsp in ipairs(lsps) do
        vim.lsp.config[lsp].capabilities = capabilities
      end

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to [D]eclaration" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to [d]efinition" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
      vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, { desc = "Rename variable or functin" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          require("lsp-format").on_attach(client, args.buf)
        end,
      })
    end,
  },
}
