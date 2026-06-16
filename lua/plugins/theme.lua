return {
	-- Monokai Pro colorscheme with transparent backgrounds for select UI
	{
		"loctvl842/monokai-pro.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("monokai-pro").setup({
				background_clear = { "toggleterm", "telescope", "renamer", "notify", "neo-tree", "snacks" },
				override = function()
					return { NormalFloat = { bg = "#221F22" } }
				end,
			})
		end,
	},
	-- Set default colorscheme for LazyVim
	{ "LazyVim/LazyVim", opts = { colorscheme = "monokai-pro" } },
}
