-- Leader key
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- Format on save (toggle with <leader>uf / <leader>uF)
vim.g.autoformat = true

local opt = vim.opt

-- General
opt.autoread = true -- auto-reload files changed externally
opt.autowrite = true
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- sync with system clipboard
opt.confirm = true -- ask to save changes before exiting a modified buffer
opt.mouse = "a"
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300 -- quickly trigger which-key
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- UI
opt.cursorline = true
opt.guifont = "Iosevka Nerd Font Mono:h11"
opt.laststatus = 3 -- global statusline
opt.list = true
opt.number = true
opt.relativenumber = false
opt.pumblend = 10
opt.pumheight = 10
opt.ruler = false
opt.scrolloff = 4
opt.showmode = false -- the statusline already shows it
opt.showtabline = 0 -- hide tabline
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smoothscroll = true
opt.termguicolors = true
opt.winminwidth = 5
opt.wrap = false
opt.linebreak = true
opt.conceallevel = 2
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

-- Editing
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.virtualedit = "block"
opt.formatoptions = "jcroqlnt"
opt.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Search & completion
opt.completeopt = "menu,menuone,noselect"
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "nosplit" -- preview incremental substitute
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.wildmode = "longest:full,full"
opt.jumpoptions = "view"
opt.spelllang = { "en" }

-- Folds (treesitter sets foldexpr per buffer, see plugins/treesitter.lua)
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldtext = ""

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- Don't let the built-in markdown ftplugin mess with indentation
vim.g.markdown_recommended_style = 0
