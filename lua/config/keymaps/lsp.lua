vim.diagnostic.config({ virtual_text = false })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local opts = { buffer = args.buf }
		local wk = vim.keymap.set

		wk("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
		wk("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
		wk("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
		wk("n", "gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
		wk("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
		wk("n", "gh", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
		wk("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
		wk("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

		wk("n", "<space>a", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
		wk("n", "<space>f", function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format" }))
		wk("n", "<space>r", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))

		wk("n", "<space>s", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Workspace symbol" }))
		wk("n", "<space>d", vim.lsp.buf.document_symbol, vim.tbl_extend("force", opts, { desc = "Document symbol" }))

		wk("n", "E", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))

		wk("n", "]d", function()
			vim.diagnostic.jump(vim.v.count1)
			vim.defer_fn(vim.diagnostic.open_float, 50)
		end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
		wk("n", "[d", function()
			vim.diagnostic.jump(-vim.v.count1)
			vim.defer_fn(vim.diagnostic.open_float, 50)
		end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
		wk("n", "<leader>le", function() Snacks.picker.diagnostics({ buf = 0 }) end, vim.tbl_extend("force", opts, { desc = "Buffer diagnostics" }))
		wk("n", "<leader>lE", function() Snacks.picker.diagnostics() end, vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
	end,
})
