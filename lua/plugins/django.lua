return {
	-- Django tooling: djlint formatter and djls LSP
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "djlint", "basedpyright" } },
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
