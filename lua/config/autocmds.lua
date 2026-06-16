-- Auto-reload buffers when file changes on disk
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Notify when a buffer is reloaded due to external change
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = vim.api.nvim_create_augroup("AutoReloadNotify", { clear = true }),
	callback = function()
		vim.cmd("echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None")
	end,
})