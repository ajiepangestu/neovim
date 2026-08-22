-- Linters that are not already covered by a language server.
--
-- Most linting here comes from LSP: ruff for python, eslint for js/ts, gopls'
-- staticcheck and analyses for go. nvim-lint only fills the gaps:
--
--   djlint       already installed as a formatter, but it also reports unclosed
--                tags and misnested blocks in Django templates.
--   golangcilint gopls runs staticcheck and a few analyses; golangci-lint adds
--                errcheck and unused on top. errcheck is the one that earns its
--                place in a Fiber project, where a dropped `err` from c.JSON()
--                or app.Listen() is otherwise silent.
return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile", "BufWritePost" },
		opts = {
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			linters_by_ft = {
				htmldjango = { "djlint" },
				go = { "golangcilint" },
			},
			-- Linters that must not run on every one of `events`. golangci-lint
			-- type-checks the whole package: measured on a two-file module it takes
			-- ~6.8s cold and ~0.3s with a warm cache, so letting it fire on
			-- InsertLeave would stall editing for nothing -- what it reports only
			-- changes once the file is written anyway.
			---@type table<string, string[]>
			events_by_linter = {
				golangcilint = { "BufWritePost" },
			},
			-- Overrides merged onto nvim-lint's own linter definitions. `args` is a
			-- list, so setting it here would replace the base arguments wholesale --
			-- for djlint that means losing `--linter-output-format`, whose shape the
			-- parser depends on, and getting no diagnostics at all. Use
			-- `prepend_args` (same name conform uses) to add to them instead.
			---@type table<string, table>
			linters = {
				djlint = {
					-- The profile the formatter already passes (see plugins/django.lua).
					-- djlint guesses the template dialect from the file contents when it
					-- is not told, and guesses differently for a template that happens to
					-- contain no `{% %}` tag.
					prepend_args = { "--profile", "django" },
				},
			},
		},
		config = function(_, opts)
			local lint = require("lint")

			for name, linter in pairs(opts.linters) do
				local base = lint.linters[name]
				if type(base) == "table" and type(linter) == "table" then
					-- Copied and stripped rather than masked: assigning `nil` in a table
					-- constructor does not remove a key, it just fails to add one, so
					-- `prepend_args` would end up on the linter definition itself.
					local override = vim.deepcopy(linter)
					local prepend = override.prepend_args
					override.prepend_args = nil
					lint.linters[name] = vim.tbl_deep_extend("force", base, override)
					if prepend then
						-- In front of the base arguments, not after: several of them end
						-- with the `-` that tells the linter to read stdin, and anything
						-- following that would be read as a filename.
						local args = vim.list_extend(vim.deepcopy(prepend), base.args or {})
						lint.linters[name].args = args
					end
				else
					lint.linters[name] = linter
				end
			end
			lint.linters_by_ft = opts.linters_by_ft

			---@param event string the autocmd event that asked for this run
			local function debounced(event)
				-- Only lint a real, readable file: linting an unnamed or deleted
				-- buffer makes the linter report against a path that does not exist.
				local buf = vim.api.nvim_get_current_buf()
				if vim.bo[buf].buftype ~= "" then
					return
				end
				local name = vim.api.nvim_buf_get_name(buf)
				if name == "" or vim.uv.fs_stat(name) == nil then
					return
				end

				local names = lint.linters_by_ft[vim.bo[buf].filetype] or {}
				names = vim.tbl_filter(function(n)
					local linter = lint.linters[n]
					if not linter then
						vim.notify("Linter not found: " .. n, vim.log.levels.WARN)
						return false
					end
					local allowed = opts.events_by_linter[n]
					if allowed and not vim.tbl_contains(allowed, event) then
						return false
					end
					return not (type(linter) == "table" and linter.condition and not linter.condition())
				end, vim.deepcopy(names))

				if #names > 0 then
					lint.try_lint(names)
				end
			end

			-- One timer per event: a cheap event firing must not cancel a debounce
			-- already pending for an expensive one.
			local timers = {}
			vim.api.nvim_create_autocmd(opts.events, {
				group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
				callback = function(args)
					local event = args.event
					timers[event] = timers[event] or assert(vim.uv.new_timer())
					timers[event]:start(
						100,
						0,
						vim.schedule_wrap(function()
							debounced(event)
						end)
					)
				end,
			})
		end,
	},

	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			-- djlint is already requested by plugins/django.lua for formatting;
			-- listed here too so this file works on its own if django.lua is removed.
			vim.list_extend(opts.ensure_installed, { "djlint", "golangci-lint" })
		end,
	},
}
