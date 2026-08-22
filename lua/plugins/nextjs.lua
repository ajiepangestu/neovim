---Run a TypeScript source action (add missing imports, fix all, ...)
---@param kind string
local function ts_action(kind)
	return function()
		vim.lsp.buf.code_action({
			context = { only = { kind }, diagnostics = {} },
			apply = true,
		})
	end
end

-- Filetypes the js-debug adapter can attach to.
local js_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

return {
	-- Emmet. The expansion itself comes from `emmet_language_server` (configured
	-- below) and shows up in the completion menu; nvim-emmet only adds the
	-- "wrap selection in an abbreviation" command on top of that server.
	-- It has no setup() of its own.
	{
		"olrtg/nvim-emmet",
		keys = {
			{
				"<leader>ce",
				mode = { "n", "v" },
				function()
					require("nvim-emmet").wrap_with_abbreviation()
				end,
				desc = "Emmet wrap with abbreviation",
			},
		},
	},

	-- ESLint for JS/TS (prettier itself is installed in plugins/lsp.lua)
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "eslint-lsp", "emmet-language-server" } },
	},

	-- Debugging with vscode-js-debug. Unlike delve and debugpy, mason-nvim-dap
	-- has no mapping for the `js` package: installing it registers nothing, so
	-- the adapters and launch configurations are written out here.
	{
		"jay-babu/mason-nvim-dap.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "js" })
		end,
	},
	{
		"mfussenegger/nvim-dap",
		optional = true,
		-- nvim-dap takes no opts of its own; lazy still runs this before the
		-- plugin's own config(), which is all this needs.
		opts = function()
			local dap = require("dap")

			-- One binary serves both adapter types; it is handed the port to listen
			-- on and nvim-dap connects back to it.
			for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
				if not dap.adapters[adapter] then
					dap.adapters[adapter] = {
						type = "server",
						host = "localhost",
						port = "${port}",
						executable = {
							command = "js-debug-adapter",
							args = { "${port}" },
						},
					}
				end
			end

			for _, ft in ipairs(js_filetypes) do
				dap.configurations[ft] = vim.list_extend(dap.configurations[ft] or {}, {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
					},
					-- Server-side Next.js: break in route handlers, server components
					-- and API routes. Equivalent to VS Code's "node-terminal" recipe.
					{
						type = "pwa-node",
						request = "launch",
						name = "Next.js: debug server side",
						runtimeExecutable = "npm",
						runtimeArgs = { "run", "dev" },
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						skipFiles = { "<node_internals>/**" },
						serverReadyAction = {
							pattern = "- Local:.+(https?://.+)",
							uriFormat = "%s",
							action = "debugWithChrome",
						},
					},
					-- Client-side: attaches to a browser against an already running
					-- dev server, so start "debug server side" (or `npm run dev`) first.
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Next.js: debug client side",
						url = "http://localhost:3000",
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
					},
				})
			end
		end,
	},

	-- Test running with neotest. Both adapters are listed because Next.js
	-- projects are split between the two runners; each one only claims a file
	-- when it finds its own runner in the project, so having both costs nothing
	-- in a project that uses just one.
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "marilari88/neotest-vitest", "nvim-neotest/neotest-jest" },
		opts = {
			adapters = {
				["neotest-vitest"] = {},
				["neotest-jest"] = {
					-- next/jest projects keep the config next to package.json rather
					-- than passing it on the command line.
					jestCommand = "npm test --",
					cwd = function(file)
						return vim.fs.root(file, { "jest.config.js", "jest.config.ts", "package.json" })
							or vim.fn.getcwd()
					end,
				},
			},
		},
	},

	-- The TS/ESLint code actions the ecosystem expects
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- Emmet abbreviations as completion items. Its default filetypes
				-- already cover html, css, scss, jsx/tsx and htmldjango.
				emmet_language_server = {},
				vtsls = {
					keys = {
						{
							"gD",
							function(client, buf)
								local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
								client:exec_cmd({
									command = "typescript.goToSourceDefinition",
									arguments = { params.textDocument.uri, params.position },
								}, { bufnr = buf }, function(_, result)
									if result and result[1] then
										vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
									else
										vim.notify("No source definition found", vim.log.levels.WARN)
									end
								end)
							end,
							desc = "Goto source definition",
						},
						{ "<leader>cM", ts_action("source.addMissingImports.ts"), desc = "Add missing imports" },
						{ "<leader>cD", ts_action("source.fixAll.ts"), desc = "Fix all diagnostics" },
						{ "<leader>co", ts_action("source.organizeImports"), desc = "Organize imports" },
					},
				},
				eslint = {
					keys = {
						{ "<leader>cE", "<cmd>LspEslintFixAll<cr>", desc = "ESLint fix all" },
					},
				},
			},
			setup = {
				eslint = function()
					-- Apply ESLint's own auto-fixes on save. prettier only reformats;
					-- the fixes worth having in a Next.js app are the rule-driven ones:
					-- unused imports, hook dependency arrays, import order.
					--
					-- Registered from an LspAttach autocmd rather than the server's
					-- `on_attach`, because setting on_attach here would replace the one
					-- lspconfig ships -- and that is what defines :LspEslintFixAll.
					--
					-- It lands before conform's own BufWritePre hook (this one is created
					-- when the server attaches, conform's when it loads on the first
					-- write), so prettier still gets the last word on layout.
					local group = vim.api.nvim_create_augroup("user_eslint_fix_on_save", { clear = true })
					vim.api.nvim_create_autocmd("LspAttach", {
						group = group,
						callback = function(args)
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							if not (client and client.name == "eslint") then
								return
							end
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = group,
								buffer = args.buf,
								callback = function(ev)
									-- Same switch as format-on-save, so <leader>uf / <leader>uF turn
									-- off the whole on-save pipeline rather than half of it.
									if require("config.util").autoformat_enabled(ev.buf) then
										pcall(vim.cmd, "LspEslintFixAll")
									end
								end,
							})
						end,
					})
				end,
			},
		},
	},
}
