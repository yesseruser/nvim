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

			-- ── Mason: auto-install adapters ─────────────────────────────────────
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = { "codelldb", "netcoredbg", "debugpy" },
				handlers = {},
			})

			-- ── Rust (codelldb, auto-build) ──────────────────────────────────────
			-- rustaceanvim's autoload_configurations is disabled below so this is
			-- the sole Rust config that appears in the <leader>dc picker.
			dap.configurations.rust = {
				{
					type = "codelldb",
					request = "launch",
					name = "Debug binary (cargo build)",
					program = function()
						-- Read package name from Cargo.toml
						local cargo_toml = vim.fn.getcwd() .. "/Cargo.toml"
						local package_name, bin_name, in_bin
						for line in io.lines(cargo_toml) do
							if line:match("^%[%[bin%]%]") then
								in_bin = true
							elseif line:match("^%[") then
								in_bin = false
							end
							local n = line:match('^name%s*=%s*"(.+)"')
							if n then
								if in_bin then
									bin_name = n
								else
									package_name = package_name or n
								end
							end
						end
						local name = bin_name or package_name
						if not name then
							vim.notify("DAP: could not find package name in Cargo.toml", vim.log.levels.ERROR)
							return vim.fn.input("Binary path: ", vim.fn.getcwd() .. "/target/debug/", "file")
						end

						vim.notify("DAP: running cargo build…", vim.log.levels.INFO)
						local out = vim.fn.system({ "cargo", "build" })
						if vim.v.shell_error ~= 0 then
							vim.notify("DAP: cargo build failed\n" .. out, vim.log.levels.ERROR)
							return nil
						end

						return vim.fn.getcwd() .. "/target/debug/" .. name
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local co = coroutine.running()
						local buf = vim.api.nvim_create_buf(false, true)
						local width = 50
						local win = vim.api.nvim_open_win(buf, true, {
							relative = "editor",
							width = width,
							height = 1,
							row = math.floor((vim.o.lines - 1) / 2),
							col = math.floor((vim.o.columns - width) / 2),
							style = "minimal",
							border = "rounded",
							title = " Debug Args ",
							title_pos = "center",
						})
						vim.cmd("startinsert")
						vim.keymap.set("i", "<CR>", function()
							local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
							vim.api.nvim_win_close(win, true)
							vim.cmd("stopinsert")
							coroutine.resume(co, vim.split(line, " ", { trimempty = true }))
						end, { buffer = buf })
						vim.keymap.set("i", "<Esc>", function()
							vim.api.nvim_win_close(win, true)
							vim.cmd("stopinsert")
							coroutine.resume(co, {})
						end, { buffer = buf })
						return coroutine.yield()
					end,
				},
			}

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
		init = function()
			vim.g.rustaceanvim = {
				tools = { hover_actions = { auto_focus = true } },
				-- autoload_configurations = false so our manual config above is the
				-- only entry in the picker, not the generic prompt-for-path one
				dap = { autoload_configurations = false },
			}
		end,
	},
}
