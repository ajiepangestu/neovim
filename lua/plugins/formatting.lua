-- prettierd is prettier kept warm as a daemon: measured on this config's own
-- fixtures a format is ~0.17s through `prettier` and ~0.07s through `prettierd`,
-- and the gap widens with plugins like prettier-plugin-tailwindcss, which
-- prettier reloads on every invocation. `prettier` stays in the list as the
-- fallback for when the daemon is not installed or refuses to start.
--
-- `stop_after_first` is what makes these lists a preference order rather than a
-- pipeline: conform runs the first formatter that is actually available.
local prettier = { "prettierd", "prettier", stop_after_first = true }

-- Same, but let a project that has adopted biome use it. biome is resolved from
-- the project's own node_modules and gated on a biome config file below, so in a
-- prettier project this entry is simply skipped.
local web = { "biome", "prettierd", "prettier", stop_after_first = true }

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
			-- Returning an empty table, not a copy of default_format_opts: conform
			-- merges the defaults above into whatever this returns, so restating
			-- them here only creates a second place to keep them in sync.
			format_on_save = function(buf)
				if not require("config.util").autoformat_enabled(buf) then
					return
				end
				return {}
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
				css = prettier,
				graphql = prettier,
				handlebars = prettier,
				html = prettier,
				javascript = web,
				javascriptreact = web,
				json = web,
				jsonc = web,
				less = prettier,
				markdown = prettier,
				["markdown.mdx"] = prettier,
				scss = prettier,
				typescript = web,
				typescriptreact = web,
				vue = prettier,
				yaml = prettier,
			},
			formatters = {
				injected = { options = { ignore_errors = true } },
				-- Only format with biome where the project asks for it. Without this
				-- gate biome would win over prettier in any repo that happens to have
				-- the binary in node_modules, config or not.
				biome = {
					condition = function(_, ctx)
						return vim.fs.root(ctx.filename, { "biome.json", "biome.jsonc" }) ~= nil
					end,
				},
			},
		},
	},
}
