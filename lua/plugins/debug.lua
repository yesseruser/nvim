return {
	-- Core DAP client
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
			{ "theHamsta/nvim-dap-virtual-text", opts = {} },
			{ "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
			"mfussenegger/nvim-dap-python",
			"NicholasMata/nvim-dap-cs",
			"nvim-lua/plenary.nvim",
		},

		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Conditional Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue / Start",
			},
			{
				"<leader>dn",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Re-run Last",
			},
			{
				"<leader>dx",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate Session",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				mode = { "n", "v" },
				desc = "Eval Expression",
			},
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")

			-- ── UI ──────────────────────────────────────────────────────────────
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.4 },
							{ id = "breakpoints", size = 0.2 },
							{ id = "stacks", size = 0.2 },
							{ id = "watches", size = 0.2 },
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 12,
						position = "bottom",
					},
				},
			})

			-- Auto open/close UI with session lifecycle
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- ── Mason: auto-install adapters ─────────────────────────────────────
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = { "codelldb", "netcoredbg", "debugpy" },
				handlers = {},
			})

			-- ── Python ───────────────────────────────────────────────────────────
			-- Detects active virtualenv automatically
			require("dap-python").setup("python")

			-- ── C# standalone (netcoredbg) ────────────────────────────────────────
			-- NOTE: netcoredbg requires libicu on Fedora: `sudo dnf install libicu`
			-- If it crashes with a globalization error, set in your shell profile:
			--   export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
			require("dap-cs").setup({
				dap_configurations = {
					{
						type = "coreclr",
						name = "Launch .NET (prompt for DLL)",
						request = "launch",
						program = function()
							return vim.fn.input("Path to .dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
						end,
					},
					{
						type = "coreclr",
						name = "Attach to .NET process",
						request = "attach",
						processId = require("dap.utils").pick_process,
					},
				},
			})

			-- ── C# Unity Mono attach ─────────────────────────────────────────────
			-- Prerequisites:
			--   1. `sudo dnf install mono-complete`
			--   2. Download UnityDebug.exe (run once):
			--        mkdir -p ~/.local/share/unity-debug/bin
			--        curl -L https://github.com/Unity-Technologies/vscode-unity-debug/releases/latest/download/unity-debug.vsix \
			--          -o /tmp/unity-debug.vsix
			--        cd /tmp && unzip -o unity-debug.vsix "extension/bin/*" -d unity_ext
			--        cp unity_ext/extension/bin/UnityDebug.exe ~/.local/share/unity-debug/bin/
			--   3. In Unity Editor: enable Development Build and use Play mode before attaching
			--
			-- If mono is not on the DAP subprocess PATH, replace "mono" below with "/usr/bin/mono"
			local unity_debug_path = vim.fn.expand("~/.local/share/unity-debug/bin/UnityDebug.exe")

			dap.adapters.unity = {
				type = "executable",
				command = "mono",
				args = { unity_debug_path },
			}

			-- Append Unity config to whatever dap-cs already registered
			vim.list_extend(dap.configurations.cs or {}, {
				{
					type = "unity",
					request = "attach",
					name = "Attach to Unity Editor",
					-- Override per-project via .vscode/launch.json instead of hardcoding
					path = vim.fn.getcwd() .. "/Library/EditorInstance.json",
				},
			})

			-- ── .vscode/launch.json auto-loading ─────────────────────────────────
			-- Strips JS-style comments which are common in launch.json files
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end

			local type_map = {
				coreclr = { "cs" },
				unity = { "cs" },
				lldb = { "rust", "c", "cpp" },
				python = { "python" },
			}

			local function load_launch_json()
				local lj = vim.fn.getcwd() .. "/.vscode/launch.json"
				if vim.fn.filereadable(lj) == 1 then
					vscode.load_launchjs(lj, type_map)
				end
			end

			load_launch_json()

			-- Re-load when changing project root
			vim.api.nvim_create_autocmd("DirChanged", { callback = load_launch_json })

			-- ── Signs ─────────────────────────────────────────────────────────────
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "✗", texthl = "DiagnosticHint" })
		end,
	},

	-- Rust: rustaceanvim manages both LSP and DAP for Rust, replacing nvim-lspconfig for it.
	-- Remove any rust_analyzer setup from your lspconfig if you add this.
	--
	-- NOTE on Fedora Asahi (aarch64): Mason's codelldb is x86_64 only.
	-- Test with: ~/.local/share/nvim/mason/bin/codelldb --version
	-- If it fails, install lldb from dnf and override the adapter:
	--   dap = { adapter = require("rustaceanvim.config.server").load_rust_adapter("/usr/bin/lldb-vscode") }
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		ft = { "rust" },
		opts = {
			tools = { hover_actions = { auto_focus = true } },
			dap = { autoload_configurations = true },
		},
	},
}
