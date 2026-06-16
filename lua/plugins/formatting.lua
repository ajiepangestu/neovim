return {
	-- Python formatting with ruff via conform.nvim
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				python = { "ruff" },
			},
		},
	},
}
