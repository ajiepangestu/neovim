-- Leader key
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- Use basedpyright for better Django ORM support
vim.g.lazyvim_python_lsp = "basedpyright"

require("config.keymaps")
require("config.monorepo")
require("config.django")
require("config.workspace")

-- UI & behavior
vim.opt.showtabline = 0          -- hide tabline
vim.opt.relativenumber = false
vim.opt.guifont = "Iosevka Nerd Font Mono:h11"
vim.opt.clipboard = "unnamedplus" -- sync with system clipboard
vim.opt.autoread = true           -- auto-reload files changed externally
