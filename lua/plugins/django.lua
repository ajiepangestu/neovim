return {
	-- Django tooling: djlint formatter and djls LSP
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "djlint", "basedpyright", "django-language-server" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- djls also claims plain `html`, so pin it to real Django projects.
				-- Without this it attaches to any html file (e.g. Go templates).
				djls = {
					workspace_required = true,
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, { "manage.py" })
						if root then
							on_dir(root)
						end
					end,
				},
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
	-- Format Django templates with djlint
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.htmldjango = { "djlint" }

			opts.formatters = opts.formatters or {}
			opts.formatters.djlint = vim.tbl_extend("force", opts.formatters.djlint or {}, {
				prepend_args = { "--profile", "django" },
			})
		end,
	},
	-- htmldjango / python / toml parsers already come from plugins/treesitter.lua,
	-- and htmldjango is a default filetype of emmet_language_server.

	-- Pick the virtualenv that basedpyright/ruff should use
	{
		"linux-cultist/venv-selector.nvim",
		ft = "python",
		cmd = "VenvSelect",
		opts = {
			options = {
				notify_user_on_venv_activation = true,
			},
		},
		keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select virtualenv", ft = "python" } },
	},
}
