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
}
