return {
	{
		"folke/snacks.nvim",
		opts = {
			input = {
				enabled = true,
			},
			picker = {
				actions = {
					opencode_send = function(picker)
						local items = vim.tbl_map(function(item)
							return item.file
									and require("opencode").format({
										path = item.file,
										from = item.pos,
										to = item.end_pos,
									})
								or item.text
						end, picker:selected({ fallback = true }))

						require("opencode").prompt(table.concat(items, ", ") .. " ")
					end,
				},
				win = {
					input = {
						keys = {
							["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
						},
					},
				},
			},
		},
	},
	{
		"nickjvandyke/opencode.nvim",
		version = "*",
		config = function()
			local opencode_cmd = "opencode --port"
			---@type snacks.terminal.Opts
			local snacks_terminal_opts = {
				win = {
					position = "right",
					enter = false,
				},
			}

			---@type opencode.Opts
			vim.g.opencode_opts = {
				server = {
					start = function()
						require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
					end,
				},
			}

			vim.o.autoread = true

			vim.keymap.set({ "n", "x" }, "<leader>oa", function()
				require("opencode").ask("@this: ")
			end, { desc = "Ask OpenCode..." })
			vim.keymap.set({ "n", "x" }, "<leader>os", function()
				require("opencode").select()
			end, { desc = "Select OpenCode..." })

			vim.keymap.set({ "n", "x" }, "go", function()
				return require("opencode").operator("@this ")
			end, { desc = "Append range to OpenCode", expr = true })
			vim.keymap.set("n", "goo", function()
				return require("opencode").operator("@this ") .. "_"
			end, { desc = "Append line to OpenCode", expr = true })

			vim.keymap.set("n", "<S-C-u>", function()
				require("opencode").command("session.half.page.up")
			end, { desc = "Scroll OpenCode up" })
			vim.keymap.set("n", "<S-C-d>", function()
				require("opencode").command("session.half.page.down")
			end, { desc = "Scroll OpenCode down" })

			vim.keymap.set({ "n", "t" }, "<C-.>", function()
				require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
			end, { desc = "Toggle OpenCode terminal" })

			vim.api.nvim_create_autocmd("User", {
				pattern = { "OpencodeEvent:tui.command.execute" },
				callback = function(args)
					local event = args.data.event
					if event.properties.command == "prompt.submit" then
						local win = require("snacks.terminal").get(opencode_cmd, { create = false })
						if win then
							win:show()
						end
					end
				end,
			})
		end,
	},
}
