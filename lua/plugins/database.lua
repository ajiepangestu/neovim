-- Talking to the database these stacks sit on: the Postgres/MySQL container in
-- compose, the one Django's ORM writes to and the one a Fiber handler queries.
--
-- lua/config/autocmds.lua already lists `dbout` in its close-with-q filetypes --
-- that is dadbod's result buffer, and until now nothing produced it.
--
-- <leader>a, not d/D/b: `<leader>d` closes the buffer, `<leader>D` is debug and
-- `<leader>b` is the buffer group. `a` is simply the free key.
return {
	-- The engine. `:DB postgres://... select 1` on its own; the UI below is what
	-- makes it usable day to day.
	{ "tpope/vim-dadbod", lazy = true, cmd = "DB" },

	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = { "tpope/vim-dadbod" },
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1

			-- `g:db_ui_save_location` is deliberately left at dadbod-ui's own
			-- default, `~/.local/share/db_ui`. It holds saved queries *and*
			-- `connections.json`, and those URLs carry passwords, so they belong
			-- outside this repository. `:DBUIAddConnection` writes there; a project
			-- can also supply a connection with no stored secret at all, since
			-- dadbod-ui reads `g:dbs` and `$DBUI_URL`.
			--
			-- dadbod-ui's own mappings are left enabled, also the default. They are
			-- buffer-local to its buffers, where <Leader>S running the query is the
			-- right primary action -- see docs/KEYMAPS.md for the three global maps
			-- they shadow there.
			--
			-- Running on `:w` is the one default that is turned off. Writes in this
			-- config already mean something (format on save, eslint fix on save),
			-- <C-s> is mapped in insert mode, and a query buffer is usually saved
			-- mid-edit. An UPDATE that runs because the buffer was saved is not a
			-- thing to discover afterwards; <Leader>S runs it deliberately.
			vim.g.db_ui_execute_on_save = 0
		end,
		-- stylua: ignore
		keys = {
			{ "<leader>au", "<cmd>DBUIToggle<cr>", desc = "Toggle database UI" },
			{ "<leader>af", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB buffer" },
			{ "<leader>ac", "<cmd>DBUIAddConnection<cr>", desc = "Add connection" },
		},
	},

	-- Completion for table and column names inside a `.sql` buffer opened from
	-- the UI: it asks the live connection for the schema.
	{
		"kristijanhusak/vim-dadbod-completion",
		dependencies = { "tpope/vim-dadbod" },
		ft = { "sql", "mysql", "plsql" },
		lazy = true,
	},

	{
		"saghen/blink.cmp",
		opts = {
			sources = {
				per_filetype = {
					-- `inherit_defaults` keeps lsp/path/snippets/buffer, the same way
					-- the lua entry in plugins/completion.lua does.
					sql = { inherit_defaults = true, "dadbod" },
					mysql = { inherit_defaults = true, "dadbod" },
					plsql = { inherit_defaults = true, "dadbod" },
				},
				providers = {
					dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				},
			},
		},
	},

	-- Already requested by plugins/treesitter.lua; repeated so this file stands
	-- on its own.
	{
		"nvim-treesitter/nvim-treesitter",
		-- `opts_extend` has to be repeated on every fragment that adds to the
		-- list, not just on the one that owns the plugin. lazy merges fragments
		-- in file order and reads `opts_extend` from the fragment being merged
		-- (or an EARLIER one); the owning spec here is alphabetically last, so at
		-- this point in the chain it is not visible yet and a plain table would
		-- REPLACE everything the files before it contributed instead of adding
		-- to it. Silently: nothing errors, the packages simply never install.
		opts_extend = { "ensure_installed" },
		opts = { ensure_installed = { "sql" } },
	},

	{
		"folke/which-key.nvim",
		-- Same reason as the `ensure_installed` fragments: `opts_extend` is read
		-- from the fragment being merged or an earlier one, and the which-key spec
		-- that declares it lives in plugins/editor.lua. Files sorting before that
		-- would otherwise REPLACE the group list instead of adding to it -- which
		-- is exactly how `<leader>D` lost its "debug" label.
		opts_extend = { "spec" },
		opts = { spec = { { "<leader>a", group = "database" } } },
	},
}
