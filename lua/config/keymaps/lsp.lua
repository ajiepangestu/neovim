-- Apply diagnostic config after LazyVim loads (LazyVim overrides it at startup)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		vim.diagnostic.config({ virtual_text = false })

		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
		end

		-- Custom navigation (Neovim 0.12 defaults: grd, grD, gri, grt, grr, K already set)
		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gh", vim.lsp.buf.hover, "Hover")
		map("<C-k>", vim.lsp.buf.signature_help, "Signature help")

		-- Actions
		map("<space>a", vim.lsp.buf.code_action, "Code action")
		map("<space>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
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
		map("<leader>le", function() Snacks.picker.diagnostics({ buf = 0 }) end, "Buffer diagnostics")
		map("<leader>lE", function() Snacks.picker.diagnostics() end, "All diagnostics")
	end,
})
