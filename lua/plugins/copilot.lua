return {
	-- GitHub Copilot with custom accept/dismiss keymaps
	{
		"zbirenbaum/copilot.lua",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<C-l>",
					accept_word = "<C-j>",
					accept_line = "<C-k>",
					next = "<C-]>",
					prev = "<C-[>",
					dismiss = "<C-\\>",
				},
			},
			panel = { enabled = false },
		},
	},
}
