return {
	-- Django tooling: djlint formatter, treesitter, djls LSP
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "djlint", "basedpyright" } },
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
				basedpyright = {
					settings = {
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								diagnosticMode = "openFilesOnly",
								autoImportCompletions = true,
							},
						},
					},
				},
			},
		},
	},
}
