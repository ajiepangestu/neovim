-- Repeat f/t forward
vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })

-- Helper: open explorer and focus
local function open_explorer()
	require("snacks").explorer()
	vim.defer_fn(function()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_explorer" then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end, 50)
end

-- Helper: check if buffer is a real file buffer
local function is_real_buffer(buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.api.nvim_buf_is_loaded(buf)
		and vim.bo[buf].buflisted
		and not vim.bo[buf].filetype:match("snacks_explorer")
end

-- Close current buffer, open explorer if none left
vim.keymap.set("n", "<leader>d", function()
	local current_buf = vim.api.nvim_get_current_buf()
	pcall(vim.api.nvim_buf_delete, current_buf, { force = true })

	local has_buf = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if is_real_buffer(buf) then
			has_buf = true
			break
		end
	end
	if not has_buf then
		open_explorer()
	end
end, { desc = "Close buffer" })

-- Close all buffers, open explorer
vim.keymap.set("n", "<leader>q", function()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if is_real_buffer(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
	open_explorer()
end, { desc = "Close all buffers" })

vim.keymap.set({ "n", "i", "x", "s" }, "<leader>w", "<cmd>w<cr><esc>", { desc = "Save" })
vim.keymap.set({ "n", "x" }, "<C-S-f>", function()
	LazyVim.format({ force = true })
end, { desc = "Format" })
