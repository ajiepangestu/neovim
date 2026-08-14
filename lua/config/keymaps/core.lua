local Util = require("config.util")
local Explorer = Util.explorer

--------------------------------------------------------------------------------
-- Editing & movement
--------------------------------------------------------------------------------

-- Move by display lines when no count is given
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Repeat f/t forward (`;` is the leader)
vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })

-- Keep the cursor centered when jumping through search results
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Escape clears the search highlight and stops an active snippet
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	if vim.snippet and vim.snippet.active() then
		vim.snippet.stop()
	end
	return "<esc>"
end, { expr = true, desc = "Escape and clear hlsearch" })

vim.keymap.set(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / clear hlsearch / diff update" }
)

-- Undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- Move lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move up" })

-- Keep the selection when indenting
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Comment above/below
vim.keymap.set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment above" })

vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- Saving.
-- <leader>w is deliberately NOT mapped in insert mode: the leader is `;`, which
-- is also the undo break-point map above, so `;w` would turn every typed
-- semicolon into a prefix and delay it by 'timeoutlen'. <C-s> covers saving
-- from insert mode and is not a prefix of anything.
vim.keymap.set({ "n", "x", "s" }, "<leader>w", "<cmd>w<cr><esc>", { desc = "Save" })
vim.keymap.set({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })

-- Formatting
vim.keymap.set({ "n", "x" }, "<C-S-f>", function()
	Util.format()
end, { desc = "Format" })
vim.keymap.set({ "n", "x" }, "<leader>cf", function()
	Util.format()
end, { desc = "Format" })

-- New file / quit
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Inspect
vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect position" })
vim.keymap.set("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, { desc = "Inspect treesitter tree" })

--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window splitting
vim.keymap.set("n", "<leader>[", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>]", "<C-w>v", { desc = "Split vertical" })

-- Window resizing
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

--------------------------------------------------------------------------------
-- Buffers, tabs & lists
--------------------------------------------------------------------------------

-- Cycle buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
vim.keymap.set("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Close other buffers" })

-- Close current buffer, open the explorer when nothing is left
vim.keymap.set("n", "<leader>d", function()
	pcall(vim.api.nvim_buf_delete, vim.api.nvim_get_current_buf(), { force = true })

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if Explorer.is_file_buffer(buf) then
			return
		end
	end
	Explorer.open()
end, { desc = "Close buffer" })

-- Close every buffer and window except the explorer (never quits nvim)
vim.keymap.set("n", "<leader>q", function()
	local explorer_win = Explorer.find_win()

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win ~= explorer_win then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if Explorer.is_file_buffer(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	if explorer_win and vim.api.nvim_win_is_valid(explorer_win) then
		vim.api.nvim_set_current_win(explorer_win)
	else
		Explorer.open()
	end
end, { desc = "Close all buffers" })

-- Quickfix & location list
vim.keymap.set("n", "<leader>xq", function()
	local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not ok and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix list" })

vim.keymap.set("n", "<leader>xl", function()
	local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not ok and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location list" })

-- Tabs
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Prev tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
