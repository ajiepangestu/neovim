local icons = require("config.icons")

return {
	-- Tool installer. Mason puts its bin dir on $PATH, so the LSP configs below
	-- find their servers without any extra glue.
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				-- servers
				"lua-language-server",
				"vtsls",
				"tailwindcss-language-server",
				"html-lsp",
				"css-lsp",
				"json-lsp",
				"yaml-language-server",
				"omnisharp",
				"fsautocomplete",
				-- tools
				"stylua",
				"shfmt",
				"ruff",
				"prettier",
				"prettierd",
				"csharpier",
				"fantomas",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)

			local registry = require("mason-registry")
			registry.refresh(function()
				-- `ensure_installed` is opts_extend, so several plugin files asking
				-- for the same tool (djlint is requested by both django.lua and
				-- lint.lua) leave duplicates in the list. Without this, the first
				-- install is still running when the second is queued -- is_installed()
				-- is false for both -- and mason downloads the package twice.
				local seen = {}
				for _, tool in ipairs(opts.ensure_installed) do
					if not seen[tool] then
						seen[tool] = true
						local ok, pkg = pcall(registry.get_package, tool)
						if ok and not pkg:is_installed() then
							pkg:install()
						end
					end
				end
			end)
		end,
	},

	-- Server configurations. nvim-lspconfig only ships the `lsp/*.lua` defaults;
	-- everything is wired up through the built-in vim.lsp.config/enable API.
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		-- blink.cmp is a dependency so its completion capabilities are available
		-- when the servers are configured below; blink does not register them
		-- itself. The gain is small and worth stating honestly: Neovim 0.12
		-- already advertises snippetSupport, insertReplaceSupport,
		-- labelDetailsSupport and resolveSupport for additionalTextEdits by
		-- default. All blink adds is `detail` and `data` to resolveSupport, which
		-- lets a server defer the signature shown in the menu to a resolve call
		-- instead of sending it for every item -- it matters for lists like the
		-- ~1000 items vtsls returns at a bare cursor. Measured: no difference in
		-- gopls/vtsls/html/cssls responses, and buffer-open time is unchanged
		-- within noise even though this makes blink load at BufReadPre.
		dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp", "b0o/schemastore.nvim" },
		-- lazy resolves these as literal dotted paths -- `*` is NOT a wildcard, it
		-- would look for a key actually named "*". List each server explicitly.
		opts_extend = { "servers.vtsls.keys", "servers.eslint.keys" },
		opts = {
			---@type vim.diagnostic.Opts
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = false, -- shown on demand with `E` / on jump
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
						[vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
						[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
						[vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
					},
				},
			},
			inlay_hints = { enabled = true, exclude = {} },
			-- Unlike document colours, code lenses are not on by default: a server
			-- that advertises them (gopls: generate, test, tidy, govulncheck, ...)
			-- shows nothing until vim.lsp.codelens.enable() is called for the
			-- buffer. Without this the `codelenses` block in plugins/go.lua is inert.
			codelens = { enabled = true },

			-- Settings merged into every server, and per-server config.
			-- Set a server to `false` to disable it.
			-- A server may also declare `keys = { { lhs, rhs, desc = ..., mode = ... } }`,
			-- which become buffer-local maps when that server attaches.
			---@type table<string, vim.lsp.Config|false>
			servers = {
				["*"] = {
					capabilities = {
						workspace = {
							fileOperations = { didRename = true, willRename = true },
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							workspace = { checkThirdParty = false },
							completion = { callSnippet = "Replace" },
							doc = { privateName = { "^_" } },
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
				-- Python: basedpyright for types, ruff for lint/fixes (see plugins/django.lua)
				ruff = {
					cmd_env = { RUFF_TRACE = "messages" },
					init_options = { settings = { logLevel = "error" } },
				},
				-- TypeScript / JavaScript
				vtsls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 30,
								completion = { enableServerSideFuzzyMatch = true },
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							-- tsserver defaults to a 3GB heap. A Next.js app of any size --
							-- app router, generated route types, a UI package -- walks into
							-- that ceiling, and the failure mode is the server dying and
							-- silently restarting rather than an error message.
							tsserver = { maxTsServerMemory = 8192 },
							preferences = {
								-- Auto-imports follow the `@/...` aliases from tsconfig paths
								-- instead of emitting "../../../lib/utils". With no paths
								-- configured TypeScript falls back to a relative specifier, so
								-- this is safe in plain projects too.
								importModuleSpecifier = "non-relative",
								-- `import type { X }` for type-only uses, which is what the
								-- Next.js compiler wants: a value import of a type drags the
								-- module into the bundle.
								preferTypeOnlyAutoImports = true,
							},
							suggest = { completeFunctionCalls = true },
							inlayHints = {
								enumMemberValues = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								variableTypes = { enabled = false },
							},
						},
					},
				},
				eslint = {},
				tailwindcss = {
					filetypes_exclude = { "markdown" },
					settings = {
						tailwindCSS = {
							includeLanguages = {
								elixir = "html-eex",
								eelixir = "html-eex",
								heex = "html-eex",
							},
							-- Classes written inside a helper call rather than in a
							-- `class=` attribute. Without this, every class in a
							-- shadcn/ui component -- which is all of them, since they
							-- go through `cn()` and `cva()` -- gets no completion, no
							-- hover and no colour swatch. `classAttributes` already
							-- covers class/className/classList by default.
							classFunctions = { "cn", "clsx", "cx", "cva", "tv", "twMerge", "twJoin" },
						},
					},
				},

				-- Tag/attribute completion, hover docs and validation for html.
				-- Complements emmet (which only expands abbreviations) and
				-- tailwindcss (which only knows class names).
				html = {},

				-- Schema-aware completion and validation for the config files that
				-- come with these stacks: tsconfig.json, package.json,
				-- docker-compose.yml, GitHub workflows. Schemas are injected from
				-- SchemaStore in the setup hooks below.
				jsonls = {
					settings = { json = { validate = { enable = true } } },
				},
				yamlls = {
					settings = {
						yaml = {
							validate = true,
							-- SchemaStore supplies these; the built-in store would
							-- otherwise fight it and produce duplicate diagnostics.
							schemaStore = { enable = false, url = "" },
						},
					},
				},

				-- Property completion, value hints and colour swatches for css.
				cssls = {
					settings = {
						css = { lint = { unknownAtRules = "ignore" } },
						scss = { lint = { unknownAtRules = "ignore" } },
						less = { lint = { unknownAtRules = "ignore" } },
					},
				},
				-- .NET
				omnisharp = {
					handlers = {
						["textDocument/definition"] = function(...)
							return require("omnisharp_extended").handler(...)
						end,
					},
					enable_roslyn_analyzers = true,
					organize_imports_on_format = true,
					enable_import_completion = true,
				},
				fsautocomplete = {},
			},

			-- Per-server hooks, run before the server is enabled.
			-- Return true to skip enabling it here.
			---@type table<string, fun(server: string, opts: vim.lsp.Config): boolean?>
			setup = {
				ruff = function()
					-- basedpyright owns hover
					vim.api.nvim_create_autocmd("LspAttach", {
						callback = function(args)
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							if client and client.name == "ruff" then
								client.server_capabilities.hoverProvider = false
							end
						end,
					})
				end,
				-- Schemas are fetched from the schemastore plugin at config time so
				-- the (large) catalogue is not built while the spec is loaded.
				jsonls = function(_, sopts)
					sopts.settings.json.schemas = require("schemastore").json.schemas()
				end,
				yamlls = function(_, sopts)
					sopts.settings.yaml.schemas = require("schemastore").yaml.schemas()
				end,
				tailwindcss = function(_, sopts)
					local defaults = vim.lsp.config.tailwindcss or {}
					sopts.filetypes = vim.list_extend(vim.deepcopy(defaults.filetypes or {}), sopts.filetypes or {})
					sopts.filetypes = vim.tbl_filter(function(ft)
						return not vim.tbl_contains(sopts.filetypes_exclude or {}, ft)
					end, sopts.filetypes)
					sopts.filetypes_exclude = nil
				end,
				vtsls = function(_, sopts)
					-- javascript inherits the typescript settings
					sopts.settings.javascript =
						vim.tbl_deep_extend("force", {}, sopts.settings.typescript, sopts.settings.javascript or {})
				end,
			},
		},
		config = function(_, opts)
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			if opts.inlay_hints.enabled then
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("user_inlay_hints", { clear = true }),
					callback = function(args)
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						local buf = args.buf
						if
							client
							and client:supports_method("textDocument/inlayHint")
							and vim.bo[buf].buftype == ""
							and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buf].filetype)
						then
							vim.lsp.inlay_hint.enable(true, { bufnr = buf })
						end
					end,
				})
			end

			if opts.codelens.enabled then
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("user_codelens", { clear = true }),
					callback = function(args)
						local client = vim.lsp.get_client_by_id(args.data.client_id)
						local buf = args.buf
						if client and client:supports_method("textDocument/codeLens") and vim.bo[buf].buftype == "" then
							-- No manual refresh loop: like inlay hints, codelens is a
							-- capability in 0.12 that attaches to the buffer and
							-- re-requests on change by itself. (`codelens.refresh()`
							-- is deprecated and just calls this.)
							vim.lsp.codelens.enable(true, { bufnr = buf })
							-- Buffer-local so the mapping exists only where there is
							-- something to run.
							vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, {
								buffer = buf,
								desc = "Run code lens",
							})
						end
					end,
				})
			end

			-- Buffer-local keymaps declared by a server spec
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lsp_server_keys", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local sopts = client and opts.servers[client.name]
					if type(sopts) ~= "table" or not sopts.keys then
						return
					end
					for _, key in ipairs(sopts.keys) do
						local rhs = key[2]
						if type(rhs) == "function" then
							local fn = rhs
							rhs = function()
								fn(client, args.buf)
							end
						end
						vim.keymap.set(key.mode or "n", key[1], rhs, { buffer = args.buf, desc = key.desc })
					end
				end,
			})

			-- Completion capabilities apply to every server, so they belong on the
			-- "*" config rather than being repeated per server.
			local star = vim.deepcopy(opts.servers["*"] or {})
			local has_blink, blink = pcall(require, "blink.cmp")
			if has_blink then
				star.capabilities =
					vim.tbl_deep_extend("force", blink.get_lsp_capabilities({}, true), star.capabilities or {})
			end
			vim.lsp.config("*", star)

			local enable = {}
			for server, sopts in pairs(opts.servers) do
				if server ~= "*" and sopts ~= false then
					sopts = sopts == true and {} or sopts
					local setup = opts.setup[server]
					if not (setup and setup(server, sopts)) then
						-- `filetypes_extra` and `root_markers_extra` append to whatever
						-- lspconfig ships, instead of replacing it like `filetypes` or
						-- `root_markers` would. They are SETS, not lists, on purpose:
						-- lazy merges maps key by key but replaces lists wholesale, so a
						-- set lets several plugin files add to the same server without
						-- clobbering one another. A `setup` hook cannot do this job --
						-- there is one per server and the last file to define it wins,
						-- silently. Sorted so the result is stable.
						local defaults = vim.lsp.config[server] or {}
						for key, extra_key in pairs({
							filetypes = "filetypes_extra",
							root_markers = "root_markers_extra",
						}) do
							if sopts[extra_key] then
								local extra = {}
								for value in pairs(sopts[extra_key]) do
									extra[#extra + 1] = value
								end
								table.sort(extra)
								sopts[key] = vim.list_extend(vim.deepcopy(defaults[key] or {}), extra)
							end
						end

						-- These three keys are ours, not vim.lsp.Config
						local cfg = {}
						for k, v in pairs(sopts) do
							if k ~= "keys" and k ~= "filetypes_extra" and k ~= "root_markers_extra" then
								cfg[k] = v
							end
						end
						vim.lsp.config(server, cfg)
						enable[#enable + 1] = server
					end
				end
			end
			vim.lsp.enable(enable)
		end,
	},

	-- Extended goto-definition for OmniSharp (decompilation, metadata, ...)
	{ "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },

	-- Lua development for this config itself
	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
				{ path = "lazy.nvim", words = { "LazySpec" } },
			},
		},
	},
}
