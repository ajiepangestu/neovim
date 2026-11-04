-- Completion engine.
local icons = require("config.icons")

return {
	-- Completion engine
	{
		"saghen/blink.cmp",
		version = "*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "rafamadriz/friendly-snippets" },
		opts_extend = { "sources.default" },
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			snippets = { preset = "default" },

			appearance = {
				nerd_font_variant = "mono",
				kind_icons = icons.kinds,
			},

			completion = {
				accept = { auto_brackets = { enabled = true } },
				menu = {
					draw = {
						treesitter = { "lsp" },
						components = {
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local icon = ctx.kind_icon
									if ctx.item.source_name == "LSP" then
										local ok, color = pcall(require, "nvim-highlight-colors")
										if ok then
											local color_item = color.format(ctx.item.documentation, { kind = ctx.kind })
											if color_item and color_item.abbr ~= "" then
												icon = color_item.abbr
											end
										end
									end
									return icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									local highlight = "BlinkCmpKind" .. ctx.kind
									if ctx.item.source_name == "LSP" then
										local ok, color = pcall(require, "nvim-highlight-colors")
										if ok then
											local color_item = color.format(ctx.item.documentation, { kind = ctx.kind })
											if color_item and color_item.abbr_hl_group then
												highlight = color_item.abbr_hl_group
											end
										end
									end
									return highlight
								end,
							},
						},
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = false },
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					lua = { inherit_defaults = true, "lazydev" },
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},

			cmdline = {
				enabled = true,
				keymap = {
					preset = "cmdline",
					["<Right>"] = false,
					["<Left>"] = false,
				},
				completion = {
					list = { selection = { preselect = false } },
					menu = {
						auto_show = function()
							return vim.fn.getcmdtype() == ":"
						end,
					},
					ghost_text = { enabled = true },
				},
			},

			keymap = {
				preset = "enter",
				["<C-y>"] = { "select_and_accept" },
			},
		},
	},
}
