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
vim.keymap.set("n", "<leader>t", function()
	Snacks.terminal.toggle(nil, { cwd = Util.root() })
end, { desc = "Toggle terminal" })

vim.keymap.set("n", "<leader>Th", function()
	Snacks.terminal.open(nil, { cwd = Util.root(), win = { position = "bottom" } })
end, { desc = "Terminal split horizontal" })

vim.keymap.set("n", "<leader>Tv", function()
	Snacks.terminal.open(nil, { cwd = Util.root(), win = { position = "right" } })
end, { desc = "Terminal split vertical" })

-- Split off another terminal without leaving terminal mode first. Reaching for
-- <Esc> instead is what a long-running TUI notices: snacks' double-escape
-- forwards the first <Esc> to the program (see snacks/terminal.lua term_normal),
-- which is an interrupt to the claude CLI. These never reach the program.
--
-- Single chords, not a prefix sequence: with 'timeoutlen' at 300ms a two-key
-- mapping only fires if the second key lands within 300ms of the first, which
-- is not reliable once a modifier has to be released in between. A chord has no
-- such window. Alt is free here -- the claude CLI only reads <A-CR>.
vim.keymap.set({ "n", "t" }, "<A-v>", function()
	Snacks.terminal.open(nil, { cwd = Util.root(), win = { position = "right" } })
end, { desc = "Terminal split vertical" })

vim.keymap.set({ "n", "t" }, "<A-s>", function()
	Snacks.terminal.open(nil, { cwd = Util.root(), win = { position = "bottom" } })
end, { desc = "Terminal split horizontal" })

vim.keymap.set({ "n", "t" }, "<A-t>", function()
	Snacks.terminal.toggle(nil, { cwd = Util.root() })
end, { desc = "Toggle terminal" })

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
