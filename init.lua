-- Personal Neovim config, managed with lazy.nvim.
-- Load order matters: options set the leader key before lazy.nvim maps anything,
-- and keymaps run last so plugin globals (Snacks, ...) are already available.
require("config.options")
require("config.lazy")
require("config.autocmds")
require("config.keymaps")

-- Custom commands
require("config.monorepo")
require("config.django")
require("config.workspace")
