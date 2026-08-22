-- Debugging. Core only -- the per-language adapters live with their stack:
-- delve in plugins/go.lua, debugpy in plugins/django.lua, js-debug in
-- plugins/nextjs.lua.
--
-- Keymaps live under <leader>D. `<leader>d` is already "close buffer", and a
-- key that is both a mapping and a prefix waits out 'timeoutlen' -- see the
-- Known Keymap Conflicts section in docs/KEYMAPS.md.
local icons = require("config.icons")

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				keys = {
					{
						"<leader>Du",
						function()
							require("dapui").toggle({})
						end,
						desc = "Toggle debug UI",
					},
					{
						"<leader>De",
						function()
							require("dapui").eval(nil, { enter = true })
						end,
						desc = "Eval expression",
						mode = { "n", "v" },
					},
				},
				opts = {},
				config = function(_, opts)
					local dap, dapui = require("dap"), require("dapui")
					dapui.setup(opts)
					-- Open the UI when a session starts and close it when it ends,
					-- so the windows never linger over normal editing.
					dap.listeners.after.event_initialized.dapui_config = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated.dapui_config = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited.dapui_config = function()
						dapui.close({})
					end
				end,
			},

			-- Inline variable values next to the code while stopped
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},

			-- Installs the debug adapters through mason
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = "mason-org/mason.nvim",
				cmd = { "DapInstall", "DapUninstall" },
				opts = {
					-- Which adapters to install is decided by the stack files, which
					-- append to `ensure_installed` (delve in plugins/go.lua, python in
					-- plugins/django.lua, js in plugins/nextjs.lua). Keep this list
					-- empty so a stack that is removed takes its adapter with it.
					ensure_installed = {},
					automatic_installation = true,
					-- An empty table means "apply the default handler to every
					-- installed adapter", which registers dap.adapters/configurations
					-- for the ones mason-nvim-dap knows about (delve, python -- but
					-- NOT js, which plugins/nextjs.lua configures by hand).
					handlers = {},
				},
			},
		},

		keys = {
			{
				"<leader>DB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Breakpoint condition",
			},
			{
				"<leader>Db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>Dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue / start",
			},
			{
				"<leader>DC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to cursor",
			},
			{
				"<leader>Di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<leader>Do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<leader>DO",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<leader>Dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>Dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run last",
			},
			{
				"<leader>Dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
		},

		config = function()
			-- Breakpoint and stopped-line signs, using the shared icon set
			for name, sign in pairs({
				Stopped = { icons.dap.Stopped, "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = { icons.dap.Breakpoint, "DiagnosticInfo" },
				BreakpointCondition = { icons.dap.BreakpointCondition, "DiagnosticInfo" },
				BreakpointRejected = { icons.dap.BreakpointRejected, "DiagnosticError" },
				LogPoint = { icons.dap.LogPoint, "DiagnosticInfo" },
			}) do
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2], linehl = sign[3], numhl = sign[3] }
				)
			end

			-- `.vscode/launch.json` needs no wiring here. nvim-dap registers a
			-- `dap.launch.json` config provider that re-reads it on every
			-- `continue()`, and its decoder already passes skip_comments to
			-- vim.json.decode. The dap.ext.vscode.load_launchjs() call this file
			-- used to make is deprecated upstream (it notifies a warning), read the
			-- file only once at startup so a later :cd kept serving the first
			-- project's configurations, and needed plenary just to strip comments.
		end,
	},

	{
		"folke/which-key.nvim",
		opts = { spec = { { "<leader>D", group = "debug" } } },
	},
}
