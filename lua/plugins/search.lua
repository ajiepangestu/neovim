return {
	-- Search and replace with VS Code-like UI
	{
		"nvim-pack/nvim-spectre",
		cmd = "Spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>sg",
				function()
					require("spectre").toggle()
				end,
				desc = "Search global (Spectre)",
			},
			{
				"<leader>sw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search word under cursor",
			},
			{
				"<leader>sf",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				desc = "Search in current file",
			},
		},
		opts = {
			color_devicons = true,
			open_cmd = "vnew",
			live_update = false,
			line_sep_start = "┌-----------------------------------------",
			result_padding = "¦  ",
			line_sep = "└-----------------------------------------",
			highlight = {
				ui = "String",
				search = "DiffChange",
				replace = "DiffDelete",
			},
			mapping = {
				["toggle_line"] = {
					map = "dd",
					cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
					desc = "Toggle item",
				},
				["enter_file"] = {
					map = "<cr>",
					cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
					desc = "Open file",
				},
				["send_to_qf"] = {
					map = "<leader>q",
					cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
					desc = "Send to quickfix",
				},
				["replace_cmd"] = {
					map = "<leader>c",
					cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
					desc = "Replace command",
				},
				["show_option_menu"] = {
					map = "<leader>o",
					cmd = "<cmd>lua require('spectre').show_options()<CR>",
					desc = "Show options",
				},
				["run_current_replace"] = {
					map = "<leader>rc",
					cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
					desc = "Replace current line",
				},
				["run_replace"] = {
					map = "<leader>R",
					cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
					desc = "Replace all",
				},
				["change_view_mode"] = {
					map = "<leader>v",
					cmd = "<cmd>lua require('spectre').change_view()<CR>",
					desc = "Change view mode",
				},
				["toggle_ignore_case"] = {
					map = "ti",
					cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
					desc = "Toggle ignore case",
				},
				["toggle_ignore_hidden"] = {
					map = "th",
					cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
					desc = "Toggle hidden files",
				},
			},
			find_engine = {
				rg = {
					cmd = "rg",
					args = {
						"--pcre2",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
					options = {
						["ignore-case"] = {
							value = "--ignore-case",
							icon = "[I]",
							desc = "ignore case",
						},
						["hidden"] = {
							value = "--hidden",
							desc = "hidden file",
							icon = "[H]",
						},
					},
				},
			},
			replace_vim_cmd = "cdo",
			is_open_target_win = true,
			is_block_ui_break = false,
		},
	},
}
