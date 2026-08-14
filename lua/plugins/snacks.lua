local Util = require("config.util")

---Terminal window navigation: <C-hjkl> moves between splits unless floating.
local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

return {
	-- The backbone of this config: picker, explorer, terminal, notifier, ...
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			quickfile = { enabled = true },
			explorer = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },

			terminal = {
				win = {
					keys = {
						nav_h = { "<C-h>", term_nav("h"), desc = "Go to left window", expr = true, mode = "t" },
						nav_j = { "<C-j>", term_nav("j"), desc = "Go to lower window", expr = true, mode = "t" },
						nav_k = { "<C-k>", term_nav("k"), desc = "Go to upper window", expr = true, mode = "t" },
						nav_l = { "<C-l>", term_nav("l"), desc = "Go to right window", expr = true, mode = "t" },
					},
				},
			},

			picker = {
				win = {
					input = {
						keys = {
							-- <a-c> flips between the project root and the cwd
							["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } },
							["<a-t>"] = { "trouble_open", mode = { "n", "i" } },
						},
					},
				},
				actions = {
					---@param p snacks.Picker
					toggle_cwd = function(p)
						local root = Util.root({ buf = p.input.filter.current_buf })
						local cwd = vim.fs.normalize(vim.uv.cwd() or ".")
						p:set_cwd(p:cwd() == root and cwd or root)
						p:find()
					end,
					trouble_open = function(...)
						return require("trouble.sources.snacks").actions.trouble_open.action(...)
					end,
				},
			},

			dashboard = {
				preset = {
					-- stylua: ignore
					keys = {
						{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
						{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
						{ icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
						{ icon = " ", key = "w", desc = "Workspaces", action = ":WorkspaceList" },
						{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
					header = [[
 ███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
 ████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
 ██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
 ██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
 ██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
 ╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]],
				},
			},
		},
		-- stylua: ignore
		keys = {
			-- top level
			{ "<leader><space>", function() Snacks.picker.files({ cwd = Util.root() }) end, desc = "Find files (root dir)" },
			{ "<leader>/", function() Snacks.picker.grep({ cwd = Util.root() }) end, desc = "Grep (root dir)" },
			{ "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
			{ "<leader>:", function() Snacks.picker.command_history() end, desc = "Command history" },
			{ "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification history" },
			{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss all notifications" },

			-- find
			{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
			{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config file" },
			{ "<leader>ff", function() Snacks.picker.files({ cwd = Util.root() }) end, desc = "Find files (root dir)" },
			{ "<leader>fF", function() Snacks.picker.files() end, desc = "Find files (cwd)" },
			{ "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find files (git-files)" },
			{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
			{ "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recent files (cwd)" },
			{ "<leader>fe", function() Snacks.explorer({ cwd = Util.root() }) end, desc = "Explorer (root dir)" },
			{ "<leader>fE", function() Snacks.explorer() end, desc = "Explorer (cwd)" },

			-- git (see plugins/git.lua for blame, diff, hunks and lazygit)
			{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
			{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git stash" },
			{ "<leader>gl", function() Snacks.picker.git_log({ cwd = Util.git_root() }) end, desc = "Git log" },
			{ "<leader>gL", function() Snacks.picker.git_log_file() end, desc = "Git log (current file)" },

			-- search (<leader>sf/sg/sw belong to Spectre, see plugins/search.lua)
			{ '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
			{ "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search history" },
			{ "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
			{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer lines" },
			{ "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep open buffers" },
			{ "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command history" },
			{ "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
			{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
			{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer diagnostics" },
			{ "<leader>sh", function() Snacks.picker.help() end, desc = "Help pages" },
			{ "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
			{ "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
			{ "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
			{ "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
			{ "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location list" },
			{ "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
			{ "<leader>sM", function() Snacks.picker.man() end, desc = "Man pages" },
			{ "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search plugin spec" },
			{ "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix list" },
			{ "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume last picker" },
			{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP symbols" },
			{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP workspace symbols" },
			{ "<leader>su", function() Snacks.picker.undo() end, desc = "Undo tree" },

			-- ui
			{ "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
		},
	},
}
