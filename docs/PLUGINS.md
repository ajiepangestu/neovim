# Plugin List

## Core

| Plugin | Description |
|--------|-------------|
| [LazyVim](https://github.com/LazyVim/LazyVim) | Neovim distribution base |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |

## UI

| Plugin | Description |
|--------|-------------|
| [monokai-pro.nvim](https://github.com/loctvl842/monokai-pro.nvim) | Colorscheme (Monokai Pro) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with orange Monokai theme |
| [barbecue.nvim](https://github.com/utilyre/barbecue.nvim) | Winbar breadcrumb (LSP context) |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP document symbol provider for breadcrumbs |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Disabled |

## AI / Completion

| Plugin | Description |
|--------|-------------|
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot with custom keymaps |

## LSP / Formatting / Linting

| Plugin | Description |
|--------|-------------|
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatter manager (see Formatters by Filetype below) |

### Formatters by Filetype

| Filetype | Formatter |
|----------|-----------|
| Python, Django | `ruff` |
| C# (.NET) | `csharpier` |
| TypeScript, JavaScript, TSX, JSX | `prettier` |
| HTML, CSS, JSON, YAML, Markdown | `prettier` |

## Language Support

| Plugin | Description |
|--------|-------------|
| [nvim-emmet](https://github.com/olrtg/nvim-emmet) | Emmet expansion for HTML/JSX/TSX |

## Git

| Plugin | Description |
|--------|-------------|
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | LazyGit integration |

## Quality of Life

| Plugin | Description |
|--------|-------------|
| [better-escape.nvim](https://github.com/max397574/better-escape.nvim) | Exit insert mode with `jj` |

## LazyVim Extras (via lazyvim.json)

| Extra | Description |
|-------|-------------|
| `ai.copilot` | Copilot integration base |
| `lang.python` | Python LSP, treesitter, debugger |
| `lang.typescript` | TypeScript/JavaScript LSP and tools |
| `lang.dotnet` | C# / .NET LSP (OmniSharp) |
| `lang.tailwind` | Tailwind CSS LSP |
| `formatting.prettier` | Prettier formatter for JS/TS/HTML/CSS |

## Mason Installed Tools

| Tool | Purpose |
|------|---------|
| `csharpier` | C# code formatter |
| `djlint` | Django template linter/formatter |
| `eslint-lsp` | ESLint language server |
| `prettierd` | Prettier daemon formatter |

## Treesitter Parsers (Extra)

| Parser | Language |
|--------|----------|
| `django` | Django templates |
