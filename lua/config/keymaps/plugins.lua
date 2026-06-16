vim.keymap.set("n", "<leader>pl", ":Lazy<CR>", { desc = "Lazy" })

-- Toggle file explorer (close if open, otherwise open)
vim.keymap.set("n", "<leader>e", function()
	local snacks = require("snacks")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "snacks_explorer" then
			vim.api.nvim_win_close(win, true)
			return
		end
	end
	snacks.explorer()
end, { desc = "Toggle explorer" })

-- Terminal toggles (all use Snacks.terminal for consistency)
vim.keymap.set({ "n", "t" }, "<leader>t", function()
	Snacks.terminal.toggle(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle terminal" })

vim.keymap.set({ "n", "t" }, "<leader>th", function()
	Snacks.terminal.open(nil, { cwd = LazyVim.root(), win = { position = "bottom" } })
end, { desc = "Terminal split horizontal" })

vim.keymap.set({ "n", "t" }, "<leader>tv", function()
	Snacks.terminal.open(nil, { cwd = LazyVim.root(), win = { position = "right" } })
end, { desc = "Terminal split vertical" })
