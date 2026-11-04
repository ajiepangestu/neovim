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
}
