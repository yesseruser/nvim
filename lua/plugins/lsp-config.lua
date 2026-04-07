local lsps = {
	"bashls",
	"clangd",
	"marksman",
	"csharp_ls",
	"lua_ls",
	"cssls",
	"tailwindcss",
	"ty",
	"ruff",
	"eslint",
	"gradle_ls",
	"phpactor",
	"luau_lsp",
	"stylua",
	"texlab",
	"hls",
	-- "rust_analyzer", - handled by rustaceanvim; see debug.lua
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

			vim.lsp.config("texlab", {
				settings = {
					["texlab"] = {
						["build"] = {
							["onSave"] = true,
						},
					},
				},
			})

			vim.lsp.config("csharp_ls", {
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local util = require("lspconfig.util")
					on_dir(
						util.root_pattern("*.sln")(fname)
							or util.root_pattern("*.csproj")(fname)
							or util.root_pattern(".git")(fname)
					)
				end,
				init_options = { AutomaticWorkspaceInit = true },
			})

			for _, lsp in ipairs(lsps) do
				vim.lsp.config(lsp, { capabilities = capabilities })
			end

			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to [D]eclaration" })
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to [d]efinition" })
			vim.keymap.set("n", "gu", require("telescope.builtin").lsp_references, { desc = "Go to [u]sages" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
			vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, { desc = "[RE]name variable or function" })
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
			vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
					if client and client.name == "csharp_ls" then
						-- Nudge csharp-ls into loading the workspace
						vim.defer_fn(function()
							vim.lsp.buf.hover()
						end, 1000)
					end
					require("lsp-format").on_attach(client, args.buf)
				end,
			})

			vim.api.nvim_create_autocmd("LspNotify", {
				callback = function(args)
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
					if client.name == "rust_analyzer" and vim.fn.exists(":LspCargoReload") > 0 then
						vim.cmd("LspCargoReload")
					end
				end,
			})
		end,
	},
}
