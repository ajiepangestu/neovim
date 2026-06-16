return {
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
}
