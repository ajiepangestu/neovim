-- Editing experience: motions, key hints, diagnostics list, todo comments,
-- pairs, text objects and session restore.
return {
	-- Jump anywhere on screen with `s`
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash search" },
		},
	},

	-- Keybinding hints
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
		opts = {
			preset = "helix",
			spec = {
				{
					mode = { "n", "x" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>b", group = "buffer" },
					{ "<leader>c", group = "code" },
					{ "<leader>f", group = "file/find" },
					{ "<leader>g", group = "git" },
					{ "<leader>l", group = "lsp" },
					{ "<leader>o", group = "opencode" },
					{ "<leader>p", group = "plugins" },
					{ "<leader>s", group = "search" },
					{ "<leader>u", group = "ui" },
					{ "<leader>x", group = "diagnostics/quickfix" },
					-- Groups live on the capital so the lowercase key stays a plain
					-- mapping: ;w saves, ;q closes buffers, ;t toggles the terminal.
					-- A key that is both a mapping and a prefix waits 'timeoutlen'.
					{ "<leader>Q", group = "quit/session" },
					{ "<leader>T", group = "terminal" },
					{ "<leader>W", group = "workspace" },
					{ "<leader>gh", group = "hunk" },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "g", group = "goto" },
					{ "z", group = "fold" },
				},
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer keymaps (which-key)",
			},
		},
	},

	-- Pretty diagnostics / references / symbols list
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {
			modes = {
				lsp = { win = { position = "right" } },
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions (Trouble)" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next trouble/quickfix item",
			},
		},
	},

	-- TODO / FIXME / HACK comments
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble" },
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
		-- stylua: ignore
		keys = {
			{ "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
			{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
			{ "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
			{ "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
		},
	},

	-- Auto pairs
	{
		"nvim-mini/mini.pairs",
		event = "VeryLazy",
		opts = {
			modes = { insert = true, command = true, terminal = false },
		},
	},

	-- Extra a/i text objects: af/if (function), ac/ic (class), a?/i? …
	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					u = ai.gen_spec.function_call(), -- u for "usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
				},
			}
		end,
	},

	-- Language aware `gc` commenting (jsx, vue, ...)
	{ "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },

	-- Exit insert mode with jj
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		opts = {
			timeout = 300,
			default_mappings = false,
			mappings = { i = { j = { j = "<Esc>" } } },
		},
	},

	-- Rainbow brackets/parentheses
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
	},

	-- EditorConfig support is built into Neovim (runtime/plugin/editorconfig.lua),
	-- so gpanders/editorconfig.nvim is no longer needed here.

	-- Session management, used by the dashboard's "Restore Session"
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		-- stylua: ignore
		keys = {
			{ "<leader>Qs", function() require("persistence").load() end, desc = "Restore session" },
			{ "<leader>QS", function() require("persistence").select() end, desc = "Select session" },
			{ "<leader>Ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
			{ "<leader>Qd", function() require("persistence").stop() end, desc = "Don't save current session" },
		},
	},
}
