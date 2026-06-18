return {
	{ "akinsho/bufferline.nvim", enabled = false },
	-- Lualine statusline with Monokai Pro orange theme
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local icons = LazyVim.config.icons

			-- Monokai-inspired mode colors
			local orange_theme = {
				normal = {
					a = { bg = "#ff9e64", fg = "#1a1a1a", gui = "bold" },
					b = { bg = "#ff6b35", fg = "#ffffff" },
					c = { bg = "#2d2d2d", fg = "#ff9e64" },
				},
				insert = {
					a = { bg = "#a9dc76", fg = "#1a1a1a", gui = "bold" },
					b = { bg = "#78dce8", fg = "#1a1a1a" },
					c = { bg = "#2d2d2d", fg = "#a9dc76" },
				},
				visual = {
					a = { bg = "#ab9df2", fg = "#1a1a1a", gui = "bold" },
					b = { bg = "#fc9867", fg = "#1a1a1a" },
					c = { bg = "#2d2d2d", fg = "#ab9df2" },
				},
				replace = {
					a = { bg = "#ff6188", fg = "#1a1a1a", gui = "bold" },
					b = { bg = "#ff9e64", fg = "#1a1a1a" },
					c = { bg = "#2d2d2d", fg = "#ff6188" },
				},
				inactive = {
					a = { bg = "#2d2d2d", fg = "#666666" },
					b = { bg = "#2d2d2d", fg = "#666666" },
					c = { bg = "#2d2d2d", fg = "#666666" },
				},
			}

			opts.options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				theme = orange_theme,
			}

			opts.sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
					{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
					{ "filename", path = 0 },
				},
				lualine_x = {
					Snacks.profiler.status(),
					{
						function()
							local venv = vim.env.VIRTUAL_ENV
							if venv then
								local name = vim.fn.fnamemodify(venv, ":t")
								return " " .. name
							end
							return ""
						end,
						cond = function()
							return vim.bo.filetype == "python" and vim.env.VIRTUAL_ENV ~= nil
						end,
						color = function() return { fg = Snacks.util.color("String") } end,
					},
					{
						function() return require("noice").api.status.command.get() end,
						cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
						color = function() return { fg = Snacks.util.color("Statement") } end,
					},
					{
						function() return require("noice").api.status.mode.get() end,
						cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
						color = function() return { fg = Snacks.util.color("Constant") } end,
					},
					{
						function() return " " .. require("dap").status() end,
						cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
						color = function() return { fg = Snacks.util.color("Debug") } end,
					},
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = function() return { fg = Snacks.util.color("Special") } end,
					},
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						source = function()
							local gitsigns = vim.b.gitsigns_status_dict
							if gitsigns then
								return {
									added = gitsigns.added,
									modified = gitsigns.changed,
									removed = gitsigns.removed,
								}
							end
						end,
					},
				},
				lualine_y = {
					{ "progress", separator = " ", padding = { left = 1, right = 0 } },
					{ "location", padding = { left = 0, right = 1 } },
				},
				lualine_z = {
				{
					function()
						local ok, opencode = pcall(require, "opencode")
						if ok then return opencode.statusline() end
						return ""
					end,
					cond = function() return package.loaded["opencode"] end,
					color = function() return { fg = Snacks.util.color("String") } end,
				},
				function() return " " .. os.date("%R") end,
			}
			}

			opts.extensions = { "neo-tree", "lazy", "fzf" }
		end,
	},
}
