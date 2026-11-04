-- Everything git: diff, hunks and gitsigns (LazyGit is in plugins/snacks.lua).
return {
	-- Enhanced diff viewer for git changes
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
		},
		opts = {
			view = {
				default = {
					layout = "diff2_horizontal",
				},
			},
		},
	},

	-- Git gutter signs, hunk actions, and line blame
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 300,
			},
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
				end

				-- stylua: ignore start
				map("n", "]h", function()
					if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
				end, "Next hunk")
				map("n", "[h", function()
					if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
				end, "Prev hunk")
				map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
				map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
				map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle git blame line")
				map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
				map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
				map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
				map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
				map("n", "<leader>ghd", gs.diffthis, "Diff this")
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
				-- stylua: ignore end
			end,
		},
	},

	-- Visual merge conflict markers resolution
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			default_mappings = true,
			disable_diagnostics = true,
		},
	},
}
