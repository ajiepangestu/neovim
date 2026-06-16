-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })

-- Window splitting
vim.keymap.set("n", "<leader>[", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>]", "<C-w>v", { desc = "Split vertical" })
