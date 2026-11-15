local Util = require("config.util")
local Explorer = Util.explorer

--------------------------------------------------------------------------------
-- Plugin UIs, explorer & terminals
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason" })

-- Toggle file explorer (close if open, otherwise open)
vim.keymap.set("n", "<leader>e", function()
	Explorer.toggle()
end, { desc = "Toggle explorer" })

-- Terminal toggles (all use Snacks.terminal for consistency).
--
-- Normal mode only: the leader is `;`, so a terminal-mode leader mapping makes
-- every `;` typed into the shell -- or into a TUI like the claude CLI -- sit
-- pending until 'timeoutlen' expires. The <A-...> keys below cover terminal mode.

---The cwd every terminal mapping below opens with.
---
---snacks derives a terminal's identity from the cwd it was opened with, so the
---SAME cwd has to come back on every call -- otherwise `toggle` fails to find
---the terminal it opened and cheerfully opens a second one instead of hiding
---the first.
---
---Util.root() alone is not stable enough for that. It answers for the current
---buffer, and a terminal buffer has no file to detect a root from, so it falls
---back to the editor's cwd -- which is a different string from the project root
---whenever nvim was started outside the project. Pressing the toggle from
---inside the terminal then opened a new one every time.
---
---So: remember the root from the last real file buffer, and keep answering with
---it while the cursor sits somewhere that cannot know better (a terminal, the
---explorer, a picker).
---@type string?
local term_root
local function terminal_cwd()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
		term_root = Util.root()
	end
	return term_root or Util.root()
end

vim.keymap.set("n", "<leader>t", function()
	Snacks.terminal.toggle(nil, { cwd = terminal_cwd() })
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "<leader>Th", function()
	Snacks.terminal.open(nil, { cwd = terminal_cwd(), win = { position = "bottom", height = 0.35 } })
end, { desc = "Terminal split horizontal (35%)" })

vim.keymap.set("n", "<leader>Tv", function()
	Snacks.terminal.open(nil, { cwd = terminal_cwd(), win = { position = "right", width = 0.40 } })
end, { desc = "Terminal split vertical (40%)" })

vim.keymap.set("n", "<leader>tf", function()
	local file_dir = vim.fn.expand("%:p:h")
	if file_dir == "" or vim.bo.buftype ~= "" then
		file_dir = terminal_cwd()
	end
	Snacks.terminal.open(nil, { cwd = file_dir, win = { position = "bottom", height = 0.35 } })
end, { desc = "Terminal in file directory" })

-- Split off another terminal without leaving terminal mode first.
vim.keymap.set({ "n", "t" }, "<A-v>", function()
	Snacks.terminal.open(nil, { cwd = terminal_cwd(), win = { position = "right", width = 0.40 } })
end, { desc = "Terminal split vertical (40%)" })

vim.keymap.set({ "n", "t" }, "<A-s>", function()
	Snacks.terminal.open(nil, { cwd = terminal_cwd(), win = { position = "bottom", height = 0.35 } })
end, { desc = "Terminal split horizontal (35%)" })

vim.keymap.set({ "n", "t" }, "<A-t>", function()
	Snacks.terminal.toggle(nil, { cwd = terminal_cwd() })
end, { desc = "Toggle terminal" })

-- Resize split windows directly from normal and terminal mode
vim.keymap.set({ "n", "t" }, "<A-Up>", "<cmd>resize +3<cr>", { desc = "Increase window height" })
vim.keymap.set({ "n", "t" }, "<A-Down>", "<cmd>resize -3<cr>", { desc = "Decrease window height" })
vim.keymap.set({ "n", "t" }, "<A-Left>", "<cmd>vertical resize -3<cr>", { desc = "Decrease window width" })
vim.keymap.set({ "n", "t" }, "<A-Right>", "<cmd>vertical resize +3<cr>", { desc = "Increase window width" })

-- REPL / Send text to terminal
local function send_to_terminal(text)
	local terms = Snacks.terminal.list()
	local target_term
	for _, t in ipairs(terms) do
		if t:win_valid() then
			target_term = t
			break
		end
	end
	if not target_term then
		target_term = Snacks.terminal.open(nil, { cwd = terminal_cwd(), win = { position = "bottom", height = 0.35 } })
	end
	if target_term and target_term.buf then
		local job_id = vim.b[target_term.buf].terminal_job_id
		if job_id then
			vim.api.nvim_chan_send(job_id, text .. "\n")
		end
	end
end

vim.keymap.set("n", "<leader>ts", function()
	send_to_terminal(vim.api.nvim_get_current_line())
end, { desc = "Send current line to terminal" })

vim.keymap.set("v", "<leader>ts", function()
	local saved_reg = vim.fn.getreg("z")
	vim.cmd('noautocmd normal! "zy')
	local text = vim.fn.getreg("z")
	vim.fn.setreg("z", saved_reg)
	send_to_terminal(text)
end, { desc = "Send selection to terminal" })

vim.keymap.set({ "n", "v" }, "<S-CR>", "<leader>ts", { remap = true, desc = "Send to terminal" })

-- Run current file in split terminal
vim.keymap.set("n", "<leader>tr", function()
	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("No file to run", vim.log.levels.WARN)
		return
	end
	local ft = vim.bo.filetype
	local cmd
	if ft == "python" then
		cmd = "python3 " .. vim.fn.shellescape(file)
	elseif ft == "go" then
		cmd = "go run " .. vim.fn.shellescape(file)
	elseif ft == "javascript" or ft == "typescript" then
		cmd = "node " .. vim.fn.shellescape(file)
	elseif ft == "sh" or ft == "bash" then
		cmd = "bash " .. vim.fn.shellescape(file)
	elseif ft == "cs" then
		cmd = "dotnet run"
	else
		cmd = "./" .. vim.fn.shellescape(vim.fn.expand("%:t"))
	end
	Snacks.terminal.open(cmd, { cwd = terminal_cwd(), win = { position = "bottom", height = 0.35 } })
end, { desc = "Run current file in terminal" })

-- Helper: find active terminal buffer (current buffer if terminal, or first visible terminal window)
local function get_active_terminal()
	if vim.bo.buftype == "terminal" then
		return vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			return buf, win
		end
	end
	local terms = Snacks.terminal.list()
	for _, t in ipairs(terms) do
		if t:win_valid() and t:buf_valid() then
			return t.buf, t.win
		end
	end
	return nil, nil
end

-- Yank / Copy all terminal output to clipboard (<leader>ty)
vim.keymap.set("n", "<leader>ty", function()
	local buf = get_active_terminal()
	if not buf then
		vim.notify("No active terminal found", vim.log.levels.WARN, { title = "Terminal" })
		return
	end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local text = table.concat(lines, "\n")
	vim.fn.setreg("+", text)
	vim.notify("Terminal buffer copied (" .. #lines .. " lines)", vim.log.levels.INFO, { title = "Terminal" })
end, { desc = "Copy all terminal output" })

-- Clear terminal screen (<leader>tc)
vim.keymap.set("n", "<leader>tc", function()
	local buf = get_active_terminal()
	if not buf then
		vim.notify("No active terminal found", vim.log.levels.WARN, { title = "Terminal" })
		return
	end
	local job_id = vim.b[buf].terminal_job_id
	if job_id then
		vim.api.nvim_chan_send(job_id, "clear\n")
	end
end, { desc = "Clear terminal screen" })

-- Quick focus jump between editor and terminal without closing it (<A-i>)
vim.keymap.set({ "n", "t" }, "<A-i>", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("wincmd p")
	else
		local _, win = get_active_terminal()
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert")
		else
			Snacks.terminal.toggle(nil, { cwd = terminal_cwd() })
		end
	end
end, { desc = "Focus editor <-> terminal" })

-- Quick search inside terminal output (<A-/>)
vim.keymap.set({ "n", "t" }, "<A-/>", function()
	local _, win = get_active_terminal()
	if not win then
		vim.notify("No active terminal found", vim.log.levels.WARN, { title = "Terminal" })
		return
	end
	vim.api.nvim_set_current_win(win)
	local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>/", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Search in terminal buffer" })

-- Scratch buffers
vim.keymap.set("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Toggle scratch buffer" })
vim.keymap.set("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select scratch buffer" })

--------------------------------------------------------------------------------
-- Toggles & git browse
--------------------------------------------------------------------------------

-- UI toggles under <leader>u, powered by Snacks.toggle.

Snacks.toggle({
	name = "Auto Format (global)",
	get = function()
		return vim.g.autoformat ~= false
	end,
	set = function(state)
		vim.g.autoformat = state
		vim.b.autoformat = nil
	end,
}):map("<leader>uf")

Snacks.toggle({
	name = "Auto Format (buffer)",
	get = function()
		local buf = vim.api.nvim_get_current_buf()
		local buf_var = vim.b[buf].autoformat
		if buf_var ~= nil then
			return buf_var
		end
		return vim.g.autoformat ~= false
	end,
	set = function(state)
		vim.b.autoformat = state
	end,
}):map("<leader>uF")

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.zen():map("<leader>uz")
Snacks.toggle.zoom():map("<leader>uZ")
Snacks.toggle
	.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
	:map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = 2, name = "Tabline" }):map("<leader>uA")

-- Open / copy the current line on the git host
vim.keymap.set({ "n", "x" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git browse (open)" })

vim.keymap.set({ "n", "x" }, "<leader>gY", function()
	Snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git browse (copy url)" })
