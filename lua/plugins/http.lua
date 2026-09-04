-- An HTTP client in a buffer, for the three backends this config targets:
-- Django REST viewsets, Fiber route handlers and Next.js route handlers all
-- need the same thing -- fire a request, read the response, keep the request
-- around. A `.http` file next to the code does that and is reviewable in git,
-- which a curl scrollback is not.
--
-- `.http` and `.rest` are detected by Neovim itself; nothing here has to add a
-- filetype.
return {
	{
		"mistweaverco/kulala.nvim",
		ft = { "http", "rest" },
		---@module "kulala"
		opts = {
			-- kulala can install its own <leader>R… prefix. The maps below are
			-- declared as lazy `keys` instead, so they load the plugin on demand and
			-- show up in which-key and `<leader>sk`. This is already kulala's
			-- default; stated so it does not change under us.
			global_keymaps = false,
			-- `kulala_keymaps` is a different thing and stays on: those are the
			-- buffer-local maps inside the response window (switch pane, show
			-- headers, jump). Turning them off would leave that window inert.
			ui = {
				-- Show the response body first; headers are one winbar pane away.
				-- `split` rather than a float, so the request stays visible beside
				-- the response.
				default_view = "body",
				display_mode = "split",
				winbar = true,
			},
			-- `default_env` is left at kulala's own default. Environments come from
			-- a `http-client.env.json` beside the file, and naming one here that a
			-- given project does not define just leaves {{variables}} unsubstituted
			-- with no error. Pick one per project with <leader>he.
		},
		-- stylua: ignore
		keys = {
			{ "<leader>hh", function() require("kulala").run() end, ft = { "http", "rest" }, desc = "Send request under cursor" },
			{ "<leader>ha", function() require("kulala").run_all() end, ft = { "http", "rest" }, desc = "Send all requests in file" },
			{ "<leader>hr", function() require("kulala").replay() end, desc = "Replay last request" },
			{ "<leader>hi", function() require("kulala").inspect() end, ft = { "http", "rest" }, desc = "Inspect request (substituted)" },
			{ "<leader>ht", function() require("kulala").toggle_view() end, ft = { "http", "rest" }, desc = "Toggle body/headers view" },
			{ "<leader>hc", function() require("kulala").copy() end, ft = { "http", "rest" }, desc = "Copy request as curl" },
			{ "<leader>hp", function() require("kulala").from_curl() end, desc = "Paste curl from clipboard as request" },
			{ "<leader>he", function() require("kulala").set_selected_env() end, desc = "Select environment" },
			{ "<leader>hs", function() require("kulala").scratchpad() end, desc = "Open scratchpad" },
			-- Not ]h/[h: gitsigns already owns those for hunks, buffer-locally, so
			-- they would win in any http file inside a git repo. r for request.
			{ "]r", function() require("kulala").jump_next() end, ft = { "http", "rest" }, desc = "Next request" },
			{ "[r", function() require("kulala").jump_prev() end, ft = { "http", "rest" }, desc = "Previous request" },
		},
	},

	-- Highlighting for the request buffer, and for the JSON/GraphQL bodies
	-- injected into it. `json` and `graphql` are already requested by
	-- plugins/treesitter.lua; `http` is the new one.
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
		opts = { ensure_installed = { "http", "json", "graphql" } },
	},

	{
		"folke/which-key.nvim",
		-- Same reason as the `ensure_installed` fragments: `opts_extend` is read
		-- from the fragment being merged or an earlier one, and the which-key spec
		-- that declares it lives in plugins/editor.lua. Files sorting before that
		-- would otherwise REPLACE the group list instead of adding to it -- which
		-- is exactly how `<leader>D` lost its "debug" label.
		opts_extend = { "spec" },
		opts = { spec = { { "<leader>h", group = "http" } } },
	},
}
