-- Markdown preview rendered inside the buffer itself: headings, tables, code
-- blocks, callouts and checkboxes drawn over the raw text. No browser, no node
-- and no deno -- it reads the same treesitter parsers already installed in
-- `lua/plugins/treesitter.lua` ("markdown" and "markdown_inline").
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
		ft = { "markdown", "markdown.mdx" },
		keys = {
			{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
		},
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			file_types = { "markdown", "markdown.mdx" },

			-- The raw text under the cursor line is un-rendered, so editing
			-- still shows the real characters.
			anti_conceal = { enabled = true },

			code = {
				-- Language name plus icon above the block, background behind it.
				width = "block",
				min_width = 45,
				right_pad = 2,
			},

			heading = {
				-- Sign column arrows duplicate the heading icons; skip them.
				sign = false,
			},

			-- Rendering LaTeX needs the `latex2text` binary (python `pylatexenc`),
			-- which this setup does not install.
			latex = { enabled = false },
		},
	},
}
