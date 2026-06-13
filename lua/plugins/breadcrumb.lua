return {
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		init = function()
			vim.g.navic_silence = true
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local buffer = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, buffer)
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
	{
		"utilyre/barbecue.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
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
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
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
				command = {
					a = { bg = "#ffd866", fg = "#1a1a1a", gui = "bold" },
					b = { bg = "#ff6b35", fg = "#1a1a1a" },
					c = { bg = "#2d2d2d", fg = "#ffd866" },
				},
				inactive = {
					a = { bg = "#2d2d2d", fg = "#666666" },
					b = { bg = "#2d2d2d", fg = "#666666" },
					c = { bg = "#2d2d2d", fg = "#666666" },
				},
			}

			opts.options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				theme = orange_theme,
			}

			for i, section in ipairs(opts.sections.lualine_b) do
				if type(section) == "table" and section[1] == "filename" then
					table.remove(opts.sections.lualine_b, i)
					break
				end
			end
		end,
	},
}
