# Commands Reference

## Plugin Management

| Command | Description |
|---------|-------------|
| `:Lazy` | Open lazy.nvim plugin manager UI |
| `:LazyGit` | Open LazyGit in floating terminal |
| `:LazyGitConfig` | Open LazyGit config |
| `:LazyGitCurrentFile` | Open LazyGit focused on current file |
| `:LazyGitFilter` | Open LazyGit with filter |
| `:LazyGitFilterCurrentFile` | Open LazyGit filtered to current file |

## Project Setup

| Command | Description |
|---------|-------------|
| `:MonorepoSetup` | Auto-generate config files for monorepo (Django + Next.js) |
| `:DjangoInstall` | Install Django dependencies with virtualenv safety checks |
| `:VenvStatus` | Check if virtualenv is currently active |

## LSP Commands (Neovim Built-in)

| Command | Description |
|---------|-------------|
| `:lua vim.lsp.buf.definition()` | Go to definition |
| `:lua vim.lsp.buf.declaration()` | Go to declaration |
| `:lua vim.lsp.buf.references()` | List references |
| `:lua vim.lsp.buf.implementation()` | Go to implementation |
| `:lua vim.lsp.buf.type_definition()` | Go to type definition |
| `:lua vim.lsp.buf.hover()` | Show hover info |
| `:lua vim.lsp.buf.signature_help()` | Show signature help |
| `:lua vim.lsp.buf.code_action()` | Show code actions |
| `:lua vim.lsp.buf.rename()` | Rename symbol |
| `:lua vim.lsp.buf.format()` | Format buffer |
| `:lua vim.lsp.buf.workspace_symbol()` | Search workspace symbols |
| `:lua vim.lsp.buf.document_symbol()` | Search document symbols |

## Diagnostic Commands

| Command | Description |
|---------|-------------|
| `:lua vim.diagnostic.open_float()` | Show diagnostic under cursor |
| `:lua vim.diagnostic.jump(1)` | Jump to next diagnostic |
| `:lua vim.diagnostic.jump(-1)` | Jump to previous diagnostic |
| `:lua vim.diagnostic.setqflist()` | Populate quickfix with diagnostics |

## Snacks / Picker Commands

| Command | Description |
|---------|-------------|
| `:lua Snacks.picker.diagnostics({ buf = 0 })` | Buffer diagnostics picker |
| `:lua Snacks.picker.diagnostics()` | All diagnostics picker |
| `:lua Snacks.explorer()` | Open file explorer |
| `:lua Snacks.terminal.toggle()` | Toggle terminal |

## Formatting

| Command | Description |
|---------|-------------|
| `:lua LazyVim.format({ force = true })` | Force format current buffer |
| `:lua vim.lsp.buf.format({ async = true })` | Async LSP format |
