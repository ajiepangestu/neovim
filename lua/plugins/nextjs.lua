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
		},
	},
}
