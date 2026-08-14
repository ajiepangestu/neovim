-- Go, including Fiber projects (html/template views).
--
-- Fiber's default view engine renders plain `.html` files containing `{{ ... }}`
-- actions. Those stay on the `html` filetype so emmet, tailwind and the html LSP
-- keep working; prettier is skipped for them further down because it reflows the
-- template actions. Files with an explicit Go template extension get the
-- `gohtmltmpl` filetype and treesitter highlighting instead.
vim.filetype.add({
	extension = {
		gohtml = "gohtmltmpl",
		gotmpl = "gohtmltmpl",
		tmpl = "gohtmltmpl",
	},
})
vim.treesitter.language.register("gotmpl", "gohtmltmpl")

---Prefer the gopls installed by the Go toolchain (`go install golang.org/x/tools/
---gopls@latest`), which is built with the local Go version — the same binary the
---VS Code Go extension manages. A distro-packaged gopls on $PATH is often several
---releases behind. Returns nil to fall back to whatever `gopls` $PATH resolves to.
local function gopls_cmd()
	local bin = vim.env.GOBIN
	if not bin or bin == "" then
		local gopath = vim.env.GOPATH
		if not gopath or gopath == "" then
			gopath = vim.fs.normalize("~/go")
		end
		bin = gopath .. "/bin"
	end
	local exe = bin .. "/gopls"
	if vim.uv.fs_stat(exe) then
		return { exe }
	end
end

---Does the buffer look like a Go html/template rather than plain html?
---@param buf number
local function is_go_template(buf)
	if vim.bo[buf].filetype ~= "html" then
		return false
	end
	local head = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 200, false), "\n")
	return head:find("{{", 1, true) ~= nil
end

return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "gofumpt", "goimports" })
			-- Only install gopls when the system doesn't already ship one; a mason
			-- gopls would shadow it on $PATH and can drift from the local toolchain.
			if vim.fn.executable("gopls") == 0 then
				table.insert(opts.ensure_installed, "gopls")
			end
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			-- Emmet in Go templates too (see plugins/nextjs.lua for the server itself)
			setup = {
				emmet_language_server = function(_, sopts)
					local defaults = vim.lsp.config.emmet_language_server or {}
					sopts.filetypes = vim.list_extend(vim.deepcopy(defaults.filetypes or {}), { "gohtmltmpl" })
				end,
				-- lspconfig lists `gotmpl`, but nothing produces that filetype here:
				-- .gohtml/.gotmpl/.tmpl are mapped to `gohtmltmpl` above so treesitter
				-- and emmet work. Without this, gopls never attaches to templates.
				gopls = function(_, sopts)
					local defaults = vim.lsp.config.gopls or {}
					sopts.filetypes = vim.list_extend(vim.deepcopy(defaults.filetypes or {}), { "gohtmltmpl" })
				end,
			},
			servers = {
				gopls = {
					cmd = gopls_cmd(),
					settings = {
						gopls = {
							gofumpt = true,
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							semanticTokens = true,
							-- Attaching gopls to templates is not enough on its own:
							-- it only analyses `{{ ... }}` in files whose extension is
							-- listed here (default is empty). Fiber's plain .html views
							-- are left out on purpose — that would treat every html
							-- file in the project as a Go template.
							templateExtensions = { "gohtml", "gotmpl", "tmpl" },
							-- Do NOT exclude `vendor`: in a vendored module every
							-- dependency lives there, and filtering it out breaks
							-- go-to-definition into third-party packages.
							directoryFilters = { "-.git", "-node_modules" },
							codelenses = {
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
						},
					},
				},
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "go", "gomod", "gosum", "gowork", "gotmpl" } },
	},

	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.go = { "goimports", "gofumpt" }

			-- Don't let prettier rewrite Fiber/Go templates that live in .html files
			opts.formatters = opts.formatters or {}
			opts.formatters.prettier = vim.tbl_extend("force", opts.formatters.prettier or {}, {
				condition = function(_, ctx)
					return not is_go_template(ctx.buf)
				end,
			})
		end,
	},
}
