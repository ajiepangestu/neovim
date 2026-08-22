-- Everything visual: colorscheme, file icons, cmdline UI, statusline, winbar.
local icons = require("config.icons")

return {
	-- Monokai Pro colorscheme with transparent backgrounds for select UI
	{
		"loctvl842/monokai-pro.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			background_clear = { "toggleterm", "telescope", "renamer", "notify", "neo-tree", "snacks" },
			override = function()
				return { NormalFloat = { bg = "#221F22" } }
			end,
		},
		config = function(_, opts)
			require("monokai-pro").setup(opts)
			vim.cmd.colorscheme("monokai-pro")
		end,
	},

	-- File type icons (also mocks nvim-web-devicons for plugins that want it)
	{
		"nvim-mini/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
				[".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
				[".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
				["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
				["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
				["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
				["manage.py"] = { glyph = "", hl = "MiniIconsGreen" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	-- Replaces the cmdline, messages and popupmenu UI
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
		-- stylua: ignore
		keys = {
			{ "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect cmdline" },
			{ "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice last message" },
			{ "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice history" },
			{ "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss all" },
			{ "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = { "i", "n", "s" } },
			{ "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = { "i", "n", "s" } },
		},
	},

	-- Lualine statusline with Monokai Pro orange theme
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				vim.o.statusline = " " -- empty statusline until lualine loads
			else
				vim.o.laststatus = 0 -- hide it on the dashboard
			end
		end,
		opts = function()
			vim.o.laststatus = vim.g.lualine_laststatus

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

			return {
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					theme = orange_theme,
					globalstatus = vim.o.laststatus == 3,
					disabled_filetypes = { statusline = { "snacks_dashboard" } },
				},
				sections = {
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
									return " " .. vim.fn.fnamemodify(venv, ":t")
								end
								return ""
							end,
							cond = function()
								return vim.bo.filetype == "python" and vim.env.VIRTUAL_ENV ~= nil
							end,
							color = function()
								return { fg = Snacks.util.color("String") }
							end,
						},
						{
							function()
								return require("noice").api.status.command.get()
							end,
							cond = function()
								return package.loaded["noice"] and require("noice").api.status.command.has()
							end,
							color = function()
								return { fg = Snacks.util.color("Statement") }
							end,
						},
						{
							function()
								return require("noice").api.status.mode.get()
							end,
							cond = function()
								return package.loaded["noice"] and require("noice").api.status.mode.has()
							end,
							color = function()
								return { fg = Snacks.util.color("Constant") }
							end,
						},
						{
							require("lazy.status").updates,
							cond = require("lazy.status").has_updates,
							color = function()
								return { fg = Snacks.util.color("Special") }
							end,
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
								if ok then
									return opencode.statusline()
								end
								return ""
							end,
							cond = function()
								return package.loaded["opencode"] ~= nil
							end,
							color = function()
								return { fg = Snacks.util.color("String") }
							end,
						},
						function()
							return " " .. os.date("%R")
						end,
					},
				},
				extensions = { "lazy", "trouble" },
			}
		end,
	},

	-- nvim-navic: LSP-powered breadcrumb context
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		init = function()
			vim.g.navic_silence = true
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, args.buf)
					end
				end,
			})
		end,
		opts = {
			separator = " > ",
			highlight = true,
			depth_limit = 5,
			icons = {
				File = " ",
				Module = " ",
				Namespace = " ",
				Package = " ",
				Class = " ",
				Method = " ",
				Property = " ",
				Field = " ",
				Constructor = " ",
				Enum = " ",
				Interface = " ",
				Function = " ",
				Variable = " ",
				Constant = " ",
				String = " ",
				Number = " ",
				Boolean = " ",
				Array = " ",
				Object = " ",
				Key = " ",
				Null = " ",
				EnumMember = " ",
				Struct = " ",
				Event = " ",
				Operator = " ",
				TypeParameter = " ",
			},
		},
	},

	-- barbecue: winbar breadcrumb UI using navic
	{
		"utilyre/barbecue.nvim",
		dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
		opts = {
			show_dirname = true,
			show_basename = true,
			theme = {
				normal = { bg = "#2d2d2d", fg = "#ff9e64" },
				separator = { fg = "#666666" },
				context = { fg = "#ff9e64" },
				context_file = { fg = "#ff9e64" },
				context_module = { fg = "#ff9e64" },
				context_namespace = { fg = "#ff9e64" },
				context_package = { fg = "#ff9e64" },
				context_class = { fg = "#ff9e64" },
				context_method = { fg = "#ff9e64" },
				context_property = { fg = "#ff9e64" },
				context_field = { fg = "#ff9e64" },
				context_constructor = { fg = "#ff9e64" },
				context_enum = { fg = "#ff9e64" },
				context_interface = { fg = "#ff9e64" },
				context_function = { fg = "#ff9e64" },
				context_variable = { fg = "#ff9e64" },
				context_constant = { fg = "#ff9e64" },
				context_string = { fg = "#ff9e64" },
				context_number = { fg = "#ff9e64" },
				context_boolean = { fg = "#ff9e64" },
				context_array = { fg = "#ff9e64" },
				context_object = { fg = "#ff9e64" },
				context_key = { fg = "#ff9e64" },
				context_null = { fg = "#ff9e64" },
				context_enum_member = { fg = "#ff9e64" },
				context_struct = { fg = "#ff9e64" },
				context_event = { fg = "#ff9e64" },
				context_operator = { fg = "#ff9e64" },
				context_type_parameter = { fg = "#ff9e64" },
			},
		},
	},
}
