local Util = require("config.util")

-- Dotfiles are part of a project, so every picker shows them. `.env*` files go a
-- step further: they're almost always gitignored, but still ours to open and grep,
-- so each source that respects .gitignore gets a second pass just for them.
local env_globs = { ".env", ".env.*" }

---`rg` args that restrict a search to env files only.
local function env_args()
	local args = {}
	for _, glob in ipairs(env_globs) do
		vim.list_extend(args, { "-g", glob })
	end
	return args
end

---Drop items an earlier finder in a `multi` source already produced.
---@param item snacks.picker.finder.Item
---@param ctx snacks.picker.finder.ctx
local function unique_match(item, ctx)
	ctx.meta.seen = ctx.meta.seen or {}
	local pos = item.pos or {}
	local key = ("%s:%s:%s"):format(item.file or item.text or "", pos[1] or 0, pos[2] or 0)
	if ctx.meta.seen[key] then
		return false
	end
	ctx.meta.seen[key] = true
end

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
				hidden = true, -- show dotfiles
				ignored = false, -- but keep honouring .gitignore

				sources = {
					-- A source can't list itself in `multi`, so the plain passes live
					-- under their own names and `files`/`grep` only combine them.
					-- `finder = false` is what hands a source over to `multi`.
					files = {
						hidden = true, -- `files` defaults to false and wins over its sub-sources
						finder = false,
						multi = { "project_files", "env_files" },
						transform = "unique_file",
					},
					grep = {
						finder = false,
						multi = { "project_grep", "env_grep" },
						transform = unique_match,
					},
					explorer = { include = { "**/.env", "**/.env.*" } },
					-- `smart` multis over "files", which no longer has a finder of its own
					smart = { multi = { "buffers", "recent", "project_files", "env_files" } },

					project_files = { finder = "files", format = "file" },
					project_grep = { finder = "grep", format = "file" },

					-- Extra passes that look *only* at env files. A positive `-g` glob
					-- makes rg override .gitignore, which is the whole point here.
					env_files = { finder = "files", format = "file", cmd = "rg", args = env_args() },
					env_grep = { finder = "grep", format = "file", glob = env_globs },
				},

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
