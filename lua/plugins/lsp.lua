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
				"omnisharp",
				"fsautocomplete",
				-- tools
				"stylua",
				"shfmt",
				"ruff",
				"prettier",
				"csharpier",
				"fantomas",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)

			local registry = require("mason-registry")
			registry.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local ok, pkg = pcall(registry.get_package, tool)
					if ok and not pkg:is_installed() then
						pkg:install()
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
		dependencies = { "mason-org/mason.nvim" },
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
						},
					},
				},

				-- Tag/attribute completion, hover docs and validation for html.
				-- Complements emmet (which only expands abbreviations) and
				-- tailwindcss (which only knows class names).
				html = {},

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

			if opts.servers["*"] then
				vim.lsp.config("*", opts.servers["*"])
			end

			local enable = {}
			for server, sopts in pairs(opts.servers) do
				if server ~= "*" and sopts ~= false then
					sopts = sopts == true and {} or sopts
					local setup = opts.setup[server]
					if not (setup and setup(server, sopts)) then
						-- `filetypes_extra` appends to whatever lspconfig ships,
						-- instead of replacing it like `filetypes` would. It is a
						-- SET, not a list, on purpose: lazy merges maps key by key
						-- but replaces lists wholesale, so a set lets several plugin
						-- files each add filetypes to the same server without
						-- clobbering one another. Sorted so the result is stable.
						if sopts.filetypes_extra then
							local extra = {}
							for ft in pairs(sopts.filetypes_extra) do
								extra[#extra + 1] = ft
							end
							table.sort(extra)
							local defaults = vim.lsp.config[server] or {}
							sopts.filetypes = vim.list_extend(vim.deepcopy(defaults.filetypes or {}), extra)
						end

						-- `keys` and `filetypes_extra` are ours, not vim.lsp.Config
						local cfg = {}
						for k, v in pairs(sopts) do
							if k ~= "keys" and k ~= "filetypes_extra" then
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
