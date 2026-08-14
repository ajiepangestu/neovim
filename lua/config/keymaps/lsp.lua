-- Buffer-local LSP keymaps.
-- Diagnostics are configured in lua/plugins/lsp.lua.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
		end

		-- Navigation through the snacks picker: jumps straight there when there is
		-- a single result, otherwise opens a list with a preview (like VS Code).
		-- Plain vim.lsp.buf.* would dump multiple results into the quickfix list.
		-- Neovim 0.12 already provides grr/gri/grt/gra/grn/grx; the first three are
		-- overridden here so they get the picker too.
		map("gd", function()
			Snacks.picker.lsp_definitions()
		end, "Go to definition")
		map("grr", function()
			Snacks.picker.lsp_references()
		end, "References")
		map("gri", function()
			Snacks.picker.lsp_implementations()
		end, "Implementations")
		map("grt", function()
			Snacks.picker.lsp_type_definitions()
		end, "Type definition")
		map("gh", vim.lsp.buf.hover, "Hover")
		-- Not <C-k>: that is window-up everywhere else, and a buffer-local map
		-- would shadow it in every buffer with an LSP attached.
		map("gs", vim.lsp.buf.signature_help, "Signature help")

		-- Actions
		map("<space>a", vim.lsp.buf.code_action, "Code action")
		map("<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, "Format")
		map("<space>r", vim.lsp.buf.rename, "Rename")

		-- Symbols
		map("<space>s", vim.lsp.buf.workspace_symbol, "Workspace symbol")
		map("<space>d", vim.lsp.buf.document_symbol, "Document symbol")

		-- Diagnostics
		map("E", vim.diagnostic.open_float, "Show diagnostic")
		map("]d", function()
			vim.diagnostic.jump({ count = vim.v.count1 })
			vim.schedule(vim.diagnostic.open_float)
		end, "Next diagnostic")
		map("[d", function()
			vim.diagnostic.jump({ count = -vim.v.count1 })
			vim.schedule(vim.diagnostic.open_float)
		end, "Previous diagnostic")
		map("<leader>le", function()
			Snacks.picker.diagnostics({ buf = 0 })
		end, "Buffer diagnostics")
		map("<leader>lE", function()
			Snacks.picker.diagnostics()
		end, "All diagnostics")
		map("<leader>li", "<cmd>checkhealth vim.lsp<cr>", "LSP info")
	end,
})
