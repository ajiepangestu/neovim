vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })
vim.keymap.set("n", "<leader>d", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>q", function()
	local bufs = vim.api.nvim_list_bufs()
	local to_delete = {}
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].filetype:match("snacks_explorer") then
			table.insert(to_delete, buf)
		end
	end
	for _, buf in ipairs(to_delete) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
	require("snacks").explorer()
end, { desc = "Close all buffers" })
vim.keymap.set({ "n", "i", "x", "s" }, "<leader>w", "<cmd>w<cr><esc>", { desc = "Save" })
vim.keymap.set({ "n", "x" }, "<C-S-f>", function()
	LazyVim.format({ force = true })
end, { desc = "Format" })
