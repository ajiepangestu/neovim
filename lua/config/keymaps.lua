-- Plugin Management
vim.keymap.set("n", "<leader>pl", ":Lazy<CR>", { desc = "Lazy" })

-- Window Navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })
vim.keymap.set("n", "<leader>[", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>]", "<C-w>s", { desc = "Split horizontal" })

-- Explorer
vim.keymap.set("n", "<leader>e", function()
	local snacks = require("snacks")

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft == "snacks_explorer" then
			vim.api.nvim_win_close(win, true)
			return
		end
	end

	snacks.explorer()
end, { desc = "Toggle explorer" })

-- Terminal
vim.keymap.set({ "n", "t" }, "<leader>t", function()
	Snacks.terminal.toggle(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle terminal" })

-- Motion
vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })
