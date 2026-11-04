-- .NET (C#) development: Omnisharp LSP, CSharpier formatting, and CoreCLR (netcoredbg) DAP.
local Util = require("config.util")

return {
	-- Tool installer for .NET
	{
		"mason-org/mason.nvim",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = { "omnisharp", "csharpier" },
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				omnisharp = {
					enable_roslyn_analyzers = true,
					organize_imports_on_format = true,
					enable_import_completion = true,
				},
			},
		},
	},

	-- C# Formatter
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				cs = { "csharpier" },
			},
		},
	},

	-- Treesitter parser
	{
		"nvim-treesitter/nvim-treesitter",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = { "c_sharp" },
		},
	},

	-- Debugging .NET with netcoredbg via DAP
	{
		"jay-babu/mason-nvim-dap.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "coreclr" })
		end,
	},
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")
			if not dap.adapters.coreclr then
				dap.adapters.coreclr = {
					type = "executable",
					command = "netcoredbg",
					args = { "--interpreter=vscode" },
				}
			end

			dap.configurations.cs = vim.list_extend(dap.configurations.cs or {}, {
				{
					type = "coreclr",
					name = ".NET: Launch DLL",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
				},
				{
					type = "coreclr",
					name = ".NET: Attach to process",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			})
		end,
	},

	-- Test runner with neotest
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "Issafalcon/neotest-dotnet" },
		opts = {
			adapters = {
				["neotest-dotnet"] = {},
			},
		},
	},
}
