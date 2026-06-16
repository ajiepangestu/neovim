return {
	-- Django tooling: djlint formatter, treesitter, djls LSP
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "djlint" } },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "django" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				djls = {},
			},
		},
	},
}
