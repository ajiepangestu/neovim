-- Angular framework tooling: angular-language-server (angularls).
--
-- Only attaches when an Angular project indicator (`angular.json`, `nx.json`, or
-- `project.json`) is found, so plain HTML and plain TS projects remain unaffected.

return {
	-- Tool installer for Angular LSP
	{
		"mason-org/mason.nvim",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = { "angular-language-server" },
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				angularls = {
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, { "angular.json", "nx.json", "project.json" })
						if root then
							on_dir(root)
						end
					end,
				},
			},
		},
	},
}
