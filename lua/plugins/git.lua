-- Everything git: blame, diff, hunks and lazygit.
return {
	-- Inline git blame (like GitLens current line blame)
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = {
			enabled = true,
			message_template = " <summary> • <date> • <author> • <<sha>>",
			date_format = "%Y-%m-%d %H:%M:%S",
			virtual_text_column = 1,
		},
		keys = {
			{ "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
			{ "<leader>go", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open commit URL" },
			{ "<leader>gc", "<cmd>GitBlameCopyCommitURL<cr>", desc = "Copy commit URL" },
			{ "<leader>gf", "<cmd>GitBlameCopyFileURL<cr>", desc = "Copy file URL" },
		},
	},

	-- Enhanced diff viewer for git changes
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
		},
		opts = {
			view = {
				default = {
					layout = "diff2_horizontal",
				},
			},
		},
	},

	-- LazyGit in a floating terminal
	{
		-- LazyGit integration: <leader>gg
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
	},

	-- Git gutter signs and hunk actions
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
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
}
