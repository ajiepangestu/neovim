require("config.keymaps-window")
require("config.keymaps-plugins")

vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })
vim.keymap.set("n", "<leader>d", ":q<CR>", { desc = "Quit" })
vim.keymap.set({ "n", "i", "x", "s" }, "<leader>w", "<cmd>w<cr><esc>", { desc = "Save" })
vim.keymap.set({ "n", "x" }, "<C-S-f>", function()
	LazyVim.format({ force = true })
end, { desc = "Format" })
