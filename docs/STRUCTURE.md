# Config Structure

Personal Neovim config on top of [lazy.nvim](https://github.com/folke/lazy.nvim).
There is no distribution layer: every plugin, option, autocmd and keymap lives in
this repository.

```
init.lua                     load order: options -> lazy -> autocmds -> keymaps -> commands
lua/config/
  lazy.lua                   lazy.nvim bootstrap and setup
  options.lua                vim options, leader key, vim.g.autoformat
  autocmds.lua               yank highlight, checktime, last location, q-to-close, ...
  icons.lua                  icon set shared by statusline / completion / diagnostics
  util.lua                   shared helpers: project root, format, treesitter, explorer
  keymaps/
    init.lua                 loads the three modules below
    core.lua                 editing & movement, windows, buffers/tabs/lists
    lsp.lua                  buffer-local LSP maps (LspAttach)
    ui.lua                   plugin UIs, explorer, terminals, <leader>u* toggles
  monorepo.lua               :MonorepoSetup
  django.lua                 :DjangoInstall, :VenvStatus
  workspace.lua              :Workspace* commands and <leader>W* maps
lua/plugins/                 one file per context, each returns a lazy.nvim spec
  snacks.lua                 picker, explorer, terminal, dashboard, notifier + picker keymaps
  lsp.lua                    mason, nvim-lspconfig, server configs, diagnostics
  completion.lua             blink.cmp (LSP, snippets, path, buffer sources)
  treesitter.lua             parsers, highlight/indent/fold wiring, textobjects
  editor.lua                 flash, which-key, trouble, todo, mini.*, better-escape,
                             rainbow-delimiters, session restore
  ui.lua                     colorscheme, mini.icons, noice, lualine, breadcrumb
  git.lua                    git-blame, diffview, lazygit, gitsigns
  formatting.lua             conform.nvim and format on save
  search.lua                 spectre search & replace
  opencode.lua               opencode AI integration
  django.lua                 Django: basedpyright/ruff/djls, djlint, mypy, venv-selector
  nextjs.lua                 Next.js: vtsls/eslint keymaps, emmet server, mdx filetype
  go.lua                     Go + Fiber: gopls, gofumpt/goimports, gotmpl templates
  docker.lua                 Docker: dockerls, hadolint, lazydocker/compose terminals
  database.lua               dadbod + dadbod-ui, SQL completion from the live connection
  http.lua                   kulala: send .http requests from the buffer
  markdown.lua               render-markdown in-buffer preview
  lint.lua                   nvim-lint wiring shared by the stack files
  dap.lua                    nvim-dap core, dap-ui, mason-nvim-dap
  test.lua                   neotest core (adapters live with their stack)
```

Each `lua/plugins/*.lua` file is one **context**, not one plugin: everything that
belongs to the same job lives together, even when it spans several plugins (all
git tooling in `git.lua`, everything visual in `ui.lua`). Language stacks own
their own file and contribute to the shared specs — a stack file may add servers
to `nvim-lspconfig`, packages to `mason.nvim`, parsers to `nvim-treesitter` and
formatters to `conform.nvim`; lazy.nvim merges those fragments.

## Things that used to come from the distro

| Was | Now |
| --- | --- |
| `LazyVim.root()` | `require("config.util").root()` |
| `LazyVim.format({ force = true })` | `require("config.util").format()` |
| `LazyVim.config.icons` | `require("config.icons")` |
| `lazyvim.json` extras | explicit plugin specs in `lua/plugins/` |
| `mason-lspconfig` auto-enable | `vim.lsp.config` / `vim.lsp.enable` in `lua/plugins/lsp.lua` |
| LazyVim format-on-save | `format_on_save` in `lua/plugins/formatting.lua`, guarded by `vim.g.autoformat` |
| `:LazyExtras` | there is no extras registry — add the plugin spec yourself |

## Per-stack docs

- Django: [DJANGO_SETUP.md](./DJANGO_SETUP.md), monorepo layout in [MONOREPO_SETUP.md](./MONOREPO_SETUP.md)
- Go / Fiber: [GO_FIBER.md](./GO_FIBER.md)
- Debugging any of them inside a container: the Debug section of
  [KEYMAPS.md](./KEYMAPS.md) — one attach configuration per stack, and what to
  start on the container side.

## Adding a language

1. Add the parser to `ensure_installed` in `lua/plugins/treesitter.lua`.
2. Add the server to `opts.servers` in `lua/plugins/lsp.lua` (the key is the
   `nvim-lspconfig` server name) and its Mason package to `ensure_installed`.
3. Add a formatter to `formatters_by_ft` in `lua/plugins/formatting.lua`.

If instead you give the language its own stack file, every fragment in it that
adds to `ensure_installed` must also carry `opts_extend = { "ensure_installed" }`
— see the note under *Mason Installed Tools* in [PLUGINS.md](./PLUGINS.md).
Without it the list is replaced rather than extended, silently.
