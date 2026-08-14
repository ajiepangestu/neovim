# Commands Reference

## Plugin Management

| Command | Description |
|---------|-------------|
| `:Lazy` | Open lazy.nvim plugin manager UI |
| `:Mason` | Open Mason UI (LSP servers and formatters) |
| `:ConformInfo` | Show the formatters conform will run for this buffer |
| `:TSUpdate` | Update treesitter parsers |
| `:VenvSelect` | Pick the Python virtualenv for the LSP |
| `:Trouble diagnostics toggle` | Toggle the diagnostics list |
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

## Workspaces

Multi-root workspaces defined in `lua/config/workspace.lua`. Every command that
takes a name will prompt for one interactively if it is omitted. See the
`<leader>w*` keymaps in `docs/KEYMAPS.md`.

| Command | Description |
|---------|-------------|
| `:WorkspaceSave [name]` | Save the current set of folders as a workspace |
| `:WorkspaceLoad [name]` | Load a saved workspace |
| `:WorkspaceList` | List all saved workspaces |
| `:WorkspaceCurrent` | Show the name of the active workspace |
| `:WorkspaceAdd [path]` | Add a folder to the current workspace |
| `:WorkspaceRemove` | Remove a folder from the current workspace |
| `:WorkspaceDelete [name]` | Delete a saved workspace |

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
| `:lua require('config.util').format()` | Force format current buffer |
| `:lua vim.lsp.buf.format({ async = true })` | Async LSP format |
