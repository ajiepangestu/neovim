return {
	-- Emmet expansion for HTML/JSX/TSX: <C-e> in insert mode
	{
		"olrtg/nvim-emmet",
		ft = { "html", "typescriptreact", "javascriptreact", "htmlangular" },
		keys = {
			{ "<C-e>", mode = "i", desc = "Emmet expand" },
		},
		config = function()
			require("nvim-emmet").setup()
		end,
	},
	-- ESLint + Prettier for JS/TS
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "eslint-lsp", "prettierd" } },
	},
}
