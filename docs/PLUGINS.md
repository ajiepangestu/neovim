# Plugin List

## Core

| Plugin | Description |
|--------|-------------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Picker, explorer, terminal, notifier, dashboard, statuscolumn |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utility library |

## UI

| Plugin | Description |
|--------|-------------|
| [monokai-pro.nvim](https://github.com/loctvl842/monokai-pro.nvim) | Colorscheme (Monokai Pro) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with orange Monokai theme |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | Winbar breadcrumb (LSP context) |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP document symbol provider for breadcrumbs |
| [noice.nvim](https://github.com/folke/noice.nvim) | Cmdline / message UI |

## LSP / Formatting / Linting

| Plugin | Description |
|--------|-------------|
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatter manager (see Formatters by Filetype below) |
| [basedpyright](https://github.com/DetachHead/basedpyright) | Python LSP with Django ORM support (replaces pyright) |

### Formatters by Filetype

| Filetype | Formatter |
|----------|-----------|
| Python | `ruff_fix` + `ruff_format` |
| Django templates | `djlint --profile django` |
| Go | `goimports` + `gofumpt` |
| C# (.NET) | `csharpier` |
| TypeScript, JavaScript, TSX, JSX | `prettier` |
| HTML, CSS, JSON, YAML, Markdown | `prettier` |

### Django ORM Setup

See [DJANGO_SETUP.md](./DJANGO_SETUP.md) for complete guide on fixing Django `objects` attribute errors with basedpyright + django-stubs.

### Monorepo Setup

See [MONOREPO_SETUP.md](./MONOREPO_SETUP.md) for setting up monorepo projects with Django API + Next.js frontend.

Use `:MonorepoSetup` command to auto-generate config files.

## Language Support

| Plugin | Description |
|--------|-------------|
| [nvim-emmet](https://github.com/olrtg/nvim-emmet) | Wrap selection with an emmet abbreviation (needs `emmet_language_server`) |

## Git

| Plugin | Description |
|--------|-------------|
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in sign column, hunk staging |
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | LazyGit integration |
| [git-blame.nvim](https://github.com/f-person/git-blame.nvim) | Inline git blame (like GitLens) |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Enhanced diff viewer for git changes |

## Search & Replace

| Plugin | Description |
|--------|-------------|
| [nvim-spectre](https://github.com/nvim-pack/nvim-spectre) | VS Code-like search and replace with live preview |

## Quality of Life

| Plugin | Description |
|--------|-------------|
| [better-escape.nvim](https://github.com/max397574/better-escape.nvim) | Exit insert mode with `jj` |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Rainbow brackets/parentheses |

## Editor

| Plugin | Description |
|--------|-------------|
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion engine (LSP, snippets, path, buffer) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parsers, highlighting, indent, folds (`main` branch) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server defaults, wired up with `vim.lsp.config`/`enable` |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Installs LSP servers and formatters |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump anywhere on screen with `s` |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics / references / symbols list |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search TODO/FIXME comments |
| [mini.ai](https://github.com/nvim-mini/mini.ai) | Extra `a`/`i` text objects |
| [mini.pairs](https://github.com/nvim-mini/mini.pairs) | Auto pairs |
| [mini.icons](https://github.com/nvim-mini/mini.icons) | File type icons |
| [ts-comments.nvim](https://github.com/folke/ts-comments.nvim) | Language aware `gc` commenting |
| [noice.nvim](https://github.com/folke/noice.nvim) | Cmdline, messages and popupmenu UI |
| [persistence.nvim](https://github.com/folke/persistence.nvim) | Session save/restore |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Lua LSP support for editing this config |
| [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim) | Pick the Python virtualenv (`<leader>cv`) |

## Language Servers

Configured in `lua/plugins/lsp.lua` (plus `django.lua` / `nextjs.lua`) and enabled with
Neovim's built-in `vim.lsp.enable`. Mason installs the binaries.

| Server | Language |
|--------|----------|
| `lua_ls` | Lua |
| `basedpyright` | Python (Django ORM aware) |
| `ruff` | Python lint / fix |
| `djls` | Django templates |
| `vtsls` | TypeScript / JavaScript |
| `eslint` | ESLint |
| `emmet_language_server` | Emmet abbreviations |
| `tailwindcss` | Tailwind CSS |
| `gopls` | Go (Fiber) |
| `omnisharp` | C# / .NET |
| `fsautocomplete` | F# |

Stack specific notes: [DJANGO_SETUP.md](./DJANGO_SETUP.md), [GO_FIBER.md](./GO_FIBER.md).

## Mason Installed Tools

Declared as `ensure_installed` across `lua/plugins/lsp.lua`, `django.lua` and
`nextjs.lua`, installed on first start.

| Tool | Purpose |
|------|---------|
| `lua-language-server` | Lua LSP |
| `basedpyright` | Python LSP with Django ORM support |
| `ruff` | Python linter / formatter |
| `django-language-server` | Django template LSP (`djls`) |
| `djlint` | Django template linter/formatter |
| `vtsls` | TypeScript / JavaScript LSP |
| `eslint-lsp` | ESLint language server |
| `tailwindcss-language-server` | Tailwind CSS LSP |
| `gofumpt`, `goimports` | Go formatters |
| `omnisharp` / `fsautocomplete` | C# / F# LSP |
| `prettier` | Prettier formatter |
| `csharpier`, `fantomas` | C# / F# formatters |
| `stylua`, `shfmt` | Lua and shell formatters |

## Treesitter Parsers

Installed automatically on first start, see `ensure_installed` in
`lua/plugins/treesitter.lua` plus the per-stack files: bash, c, c_sharp, css,
diff, fsharp, go, gomod, gosum, gotmpl, gowork, html, htmldjango, ini,
javascript, jsdoc, json, lua, luadoc, luap, markdown, markdown_inline, printf,
python, query, regex, scss, toml, tsx, typescript, vim, vimdoc, xml, yaml.
