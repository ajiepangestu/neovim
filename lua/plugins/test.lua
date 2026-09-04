-- Running tests from the editor. Core only -- the per-language adapters live
-- with their stack, the same way the debug adapters do: neotest-golang in
-- plugins/go.lua, neotest-python in plugins/django.lua, neotest-vitest and
-- neotest-jest in plugins/nextjs.lua.
--
-- Keymaps live under <leader>N. `<leader>t` is already "toggle terminal" and
-- <leader>T its split group, so the obvious letter is taken twice over; N is
-- for neotest. A key that is both a mapping and a prefix waits out 'timeoutlen'
-- -- see the Known Keymap Conflicts section in docs/KEYMAPS.md.
local icons = require("config.icons")

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- `["module name"] = config`, not ready-made adapter instances. The
			-- stack files fill this in; keeping it plain data means lazy merges the
			-- fragments by key, and -- more importantly -- nothing has to require an
			-- adapter module while opts are being resolved. An opts function that
			-- errors is discarded by lazy *silently*, and requiring an adapter that
			-- is not on the runtimepath yet is exactly how that happens: the result
			-- is neotest starting up with no adapters and no error to explain it.
			---@type table<string, table>
			adapters = {},
			status = { virtual_text = true, signs = false },
			output = { open_on_run = false },
			quickfix = {
				-- Trouble and the quickfix list are already bound to <leader>x*;
				-- opening the list on every run would fight the summary window.
				enabled = true,
				open = false,
			},
			icons = {
				passed = icons.test.Passed,
				failed = icons.test.Failed,
				running = icons.test.Running,
				skipped = icons.test.Skipped,
			},
		},
		-- stylua: ignore
		keys = {
			{ "<leader>Nr", function() require("neotest").run.run() end, desc = "Run nearest test" },
			{ "<leader>Nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in file" },
			{ "<leader>Na", function() require("neotest").run.run({ suite = true }) end, desc = "Run whole suite" },
			{ "<leader>Nl", function() require("neotest").run.run_last() end, desc = "Run last test" },
			{ "<leader>Nx", function() require("neotest").run.stop() end, desc = "Stop running test" },
			{ "<leader>Ns", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
			{ "<leader>No", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
			{ "<leader>NO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
			{ "<leader>Nw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle watch file" },
			-- Runs the test under the cursor through nvim-dap, using the adapter's
			-- own debug strategy (delve for go, debugpy for python, js-debug for
			-- vitest/jest). The debug UI from plugins/dap.lua opens with it.
			{ "<leader>Nd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
		},
		config = function(_, opts)
			-- neotest reports failures as diagnostics; give them the same namespace
			-- treatment as LSP diagnostics so `E` and Trouble pick them up.
			vim.diagnostic.config({
				virtual_text = {
					format = function(diagnostic)
						return (diagnostic.message or ""):gsub("\n", " "):gsub("%s+", " ")
					end,
				},
			}, vim.api.nvim_create_namespace("neotest"))

			-- Instantiated here, where every adapter is guaranteed to be on the
			-- runtimepath: all four are callables that take their config table.
			local adapters = {}
			for name, cfg in pairs(opts.adapters) do
				adapters[#adapters + 1] = require(name)(cfg)
			end
			opts.adapters = adapters

			require("neotest").setup(opts)
		end,
	},

	{
		"folke/which-key.nvim",
		-- Same reason as the `ensure_installed` fragments: `opts_extend` is read
		-- from the fragment being merged or an earlier one, and the which-key spec
		-- that declares it lives in plugins/editor.lua. Files sorting before that
		-- would otherwise REPLACE the group list instead of adding to it -- which
		-- is exactly how `<leader>D` lost its "debug" label.
		opts_extend = { "spec" },
		opts = { spec = { { "<leader>N", group = "test" } } },
	},
}
