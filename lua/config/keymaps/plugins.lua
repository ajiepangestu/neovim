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

-- Terminal toggles
vim.keymap.set({ "n", "t" }, "<leader>t", function()
	Snacks.terminal.toggle(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "<leader>th", function()
	vim.cmd("split | terminal")
	vim.cmd("startinsert")
end, { desc = "Terminal split horizontal" })

vim.keymap.set("n", "<leader>tv", function()
	vim.cmd("vsplit | terminal")
	vim.cmd("startinsert")
end, { desc = "Terminal split vertical" })

vim.keymap.set("t", "<leader>th", function()
	vim.cmd("stopinsert")
	vim.cmd("split | terminal")
	vim.cmd("startinsert")
end, { desc = "Terminal split horizontal" })

vim.keymap.set("t", "<leader>tv", function()
	vim.cmd("stopinsert")
	vim.cmd("vsplit | terminal")
	vim.cmd("startinsert")
end, { desc = "Terminal split vertical" })
