local Util = require("config.util")

return {
	-- Parsers, highlighting, indentation and folds
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "VeryLazy" },
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"c_sharp",
				"css",
				"diff",
				"fsharp",
				"html",
				"htmldjango",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"scss",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
		},
		config = function(_, opts)
			local TS = require("nvim-treesitter")
			TS.setup(opts)
			Util.ts.installed(true)

			local missing = vim.tbl_filter(function(lang)
				return not Util.ts.installed()[lang]
			end, opts.ensure_installed)
			if #missing > 0 then
				TS.install(missing, { summary = true }):await(function()
					Util.ts.installed(true)
				end)
			end

			-- The `main` branch has no automatic attaching: enable the features
			-- we want per buffer, but only when a parser and query exist.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
				callback = function(ev)
					local ft = ev.match
					if not Util.ts.have(ft) then
						return
					end

					if Util.ts.have(ft, "highlights") then
						pcall(vim.treesitter.start, ev.buf)
					end
					if Util.ts.have(ft, "indents") then
						Util.set_default("indentexpr", "v:lua.require'nvim-treesitter'.indentexpr()")
					end
					if Util.ts.have(ft, "folds") then
						if Util.set_default("foldmethod", "expr") then
							Util.set_default("foldexpr", "v:lua.vim.treesitter.foldexpr()")
						end
					end
				end,
			})
		end,
	},

	-- ]f / [c / ]a … motions over functions, classes and parameters
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		opts = {
			move = {
				enable = true,
				set_jumps = true,
			},
		},
		config = function(_, opts)
			require("nvim-treesitter-textobjects").setup(opts)

			local moves = {
				goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
				goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
					["[a"] = "@parameter.inner",
				},
				goto_previous_end = {
					["[F"] = "@function.outer",
					["[C"] = "@class.outer",
					["[A"] = "@parameter.inner",
				},
			}

			local function attach(buf)
				if not (vim.api.nvim_buf_is_valid(buf) and Util.ts.have(vim.bo[buf].filetype, "textobjects")) then
					return
				end
				for method, keymaps in pairs(moves) do
					for key, query in pairs(keymaps) do
						vim.keymap.set({ "n", "x", "o" }, key, function()
							if vim.wo.diff and key:find("[cC]") then
								return vim.cmd("normal! " .. key)
							end
							require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
						end, { buffer = buf, silent = true, desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. query })
					end
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("user_treesitter_textobjects", { clear = true }),
				callback = function(ev)
					attach(ev.buf)
				end,
			})
			vim.tbl_map(attach, vim.api.nvim_list_bufs())
		end,
	},

	-- Auto close/rename HTML and JSX tags
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},
}
