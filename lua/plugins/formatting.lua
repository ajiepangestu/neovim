return {
	-- Formatting. Runs on save unless disabled with <leader>uf / <leader>uF.
	{
		"stevearc/conform.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = { "BufWritePre" },
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "x" },
				desc = "Format injected langs",
			},
		},
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},
			format_on_save = function(buf)
				if vim.b[buf].autoformat == false then
					return
				end
				if vim.b[buf].autoformat == nil and vim.g.autoformat == false then
					return
				end
				return { timeout_ms = 3000, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
				fish = { "fish_indent" },
				-- `ruff_fix` is what the old `ruff` entry resolved to; `ruff_format`
				-- is the actual formatter.
				python = { "ruff_fix", "ruff_format" },
				cs = { "csharpier" },
				fsharp = { "fantomas" },
				css = { "prettier" },
				graphql = { "prettier" },
				handlebars = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				less = { "prettier" },
				markdown = { "prettier" },
				["markdown.mdx"] = { "prettier" },
				scss = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				yaml = { "prettier" },
			},
			formatters = {
				injected = { options = { ignore_errors = true } },
			},
		},
	},
}
