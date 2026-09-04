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
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Linters the language servers do not cover: `djlint` for Django templates, `hadolint` for Dockerfiles, `golangci-lint` for Go and `mypy` for Python (the last two on write only — both check far more than the file). `mypy` additionally runs only where the project has a mypy config *and* a venv containing mypy, since outside the venv it has no `django-stubs` |
| [neotest](https://github.com/nvim-neotest/neotest) | Test runner, keys under `<leader>N`. Adapters: [neotest-golang](https://github.com/fredrikaverpil/neotest-golang), [neotest-python](https://github.com/nvim-neotest/neotest-python), [neotest-vitest](https://github.com/marilari88/neotest-vitest), [neotest-jest](https://github.com/nvim-neotest/neotest-jest) |

### Formatters by Filetype

| Filetype | Formatter |
|----------|-----------|
| Python | `ruff_fix` + `ruff_format` |
| Django templates | `djlint --profile django` |
| Go | `goimports` + `gofumpt` |
| C# (.NET) | `csharpier` |
| TypeScript, JavaScript, TSX, JSX, JSON | `biome` if the project has a `biome.json`, else `prettierd`, else `prettier` |
| HTML, CSS, YAML (compose files included), Markdown, MDX | `prettierd`, falling back to `prettier` |

`prettierd` is prettier kept warm as a daemon (~0.07s per format against ~0.17s
for `prettier`). Go templates living in `.html` files are excluded — see
`is_go_template` in `lua/plugins/go.lua`.

Dockerfiles have no conform entry on purpose: there is no maintained standalone
Dockerfile formatter, and `dockerls` implements `textDocument/formatting`. With
`lsp_format = "fallback"` in `default_format_opts`, conform hands the buffer to
the server, so `<leader>cf` and format-on-save work there without one. It is
configured with `ignoreMultilineInstructions`, which leaves the body of a
`RUN … && \` chain exactly as written.

ESLint's own auto-fixes are applied on save in buffers where the eslint server
is attached, before prettier runs. `<leader>uf` / `<leader>uF` turn that off
along with the rest of format-on-save.

### Django ORM Setup

See [DJANGO_SETUP.md](./DJANGO_SETUP.md) for complete guide on fixing Django `objects` attribute errors with basedpyright + django-stubs.

### Monorepo Setup

See [MONOREPO_SETUP.md](./MONOREPO_SETUP.md) for setting up monorepo projects with Django API + Next.js frontend.

Use `:MonorepoSetup` command to auto-generate config files.

## Language Support

| Plugin | Description |
|--------|-------------|
| [nvim-emmet](https://github.com/olrtg/nvim-emmet) | Wrap selection with an emmet abbreviation (needs `emmet_language_server`) |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | In-buffer markdown preview: headings, tables, code blocks, callouts and checkboxes drawn over the raw text. No browser or extra runtime — it reuses the `markdown` / `markdown_inline` parsers. Toggle with `<leader>um`. Also covers `.mdx` |
| [kulala.nvim](https://github.com/mistweaverco/kulala.nvim) | HTTP client: send the request under the cursor from a `.http` file and read the response in a split. Keys under `<leader>h` |
| [vim-dadbod](https://github.com/tpope/vim-dadbod) | Database client (`:DB`) |
| [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | Drawer over dadbod: connections, tables, saved queries. Keys under `<leader>a` |
| [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion) | Table and column completion in SQL buffers, wired into blink.cmp as the `dadbod` source |

### MDX

`.mdx` has no filetype rule in Neovim, so those files used to fall through to
`conf`: no useful highlighting, no prettier, and `render-markdown` never
triggering — while `formatters_by_ft` and the render-markdown spec were already
written against a `markdown.mdx` filetype that nothing produced.
`lua/plugins/nextjs.lua` now registers it, maps it to the `markdown` parser, and
`lua/config/autocmds.lua` lists it alongside `markdown` for wrap and spell (a
FileType autocmd matches the filetype string whole, so `markdown` alone does not
cover `markdown.mdx`).

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
| `html` | HTML tags, attributes, validation |
| `cssls` | CSS / SCSS / LESS properties and colours |
| `gopls` | Go (Fiber) |
| `dockerls` | Dockerfile instructions, flags and formatting |
| `omnisharp` | C# / .NET |
| `fsautocomplete` | F# |

### Which server answers in a markup buffer

Four servers cover markup and they do different jobs, so several attach at once.

| Filetype | Servers attached | Each contributes |
|----------|------------------|------------------|
| `html` | `html`, `emmet_language_server`, `tailwindcss` (+ `djls` in a Django project) | tags/attributes, abbreviation expansion, class names |
| `htmldjango` | `html`, `djls`, `emmet_language_server`, `tailwindcss` | as above, plus `{% %}` / `{{ }}` from djls |
| `gohtmltmpl` | `html`, `gopls`, `emmet_language_server`, `tailwindcss` | as above, plus `{{ }}` action diagnostics from gopls |
| `css` / `scss` | `cssls`, `emmet_language_server`, `tailwindcss` | properties and colours, abbreviations, class names |
| `typescriptreact` | `vtsls`, `emmet_language_server`, `tailwindcss` (+ `eslint` when the project has a config) | types, abbreviations, class names |

`cssls` is configured with `lint.unknownAtRules = "ignore"` for css, scss and
less. Without it every `@tailwind` and `@apply` directive is reported as an
error. Real mistakes are still caught — a `colr: red` typo still reports
`Unknown property`.

The `html` server ships with `filetypes = { "html" }` only. `htmldjango` and
`gohtmltmpl` are added through `filetypes_extra` (see below), because Django and
Go templates are html with a template syntax layered on top — verified to
produce no false diagnostics on `{% if %}` or `{{ }}` inside attributes.

### `filetypes_extra` and `root_markers_extra`

A server spec may set either of these, a **set** of values to append to whatever
lspconfig ships, rather than replacing the list like `filetypes` / `root_markers`
would:

```lua
html = { filetypes_extra = { htmldjango = true } }             -- in django.lua
html = { filetypes_extra = { gohtmltmpl = true } }             -- in go.lua
ruff = { root_markers_extra = { ["manage.py"] = true } }       -- in django.lua
```

They are sets and not lists on purpose. lazy.nvim merges maps key by key but
replaces lists wholesale, so two plugin files each adding a list to the same
server would silently lose one of them. `opts_extend` does not help here: its
dotted paths are literal, so `servers.*.keys` looks for a key actually named
`*` and never matches.

A `setup` hook cannot do this job either. There is exactly one per server, and
whichever plugin file is merged last silently replaces the others — `lua/plugins`
is imported in alphabetical order, so `django.lua` defining `setup.ruff` would
have thrown away the one in `lsp.lua` that hands hover to basedpyright.

Stack specific notes: [DJANGO_SETUP.md](./DJANGO_SETUP.md), [GO_FIBER.md](./GO_FIBER.md).

## Mason Installed Tools

Declared as `ensure_installed` across `lua/plugins/lsp.lua`, `django.lua`,
`docker.lua`, `nextjs.lua`, `go.lua` and `lint.lua`, installed on first start.
Duplicate requests are de-duplicated before install.

Every one of those fragments repeats `opts_extend = { "ensure_installed" }`, and
so do the `nvim-treesitter` fragments in the per-stack files. This is not
redundancy. lazy merges fragments in file order and reads `opts_extend` from the
fragment currently being merged or an *earlier* one, so declaring it only on the
spec that owns the plugin covers just the fragments that sort after it —
`lsp.lua` and `treesitter.lua` are both late in the alphabet, so most stack
files fall before them. A plain `ensure_installed` table at that point in the
chain **replaces** everything the earlier files asked for rather than adding to
it, and nothing reports the loss: the packages simply never install.

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
| `html-lsp` | HTML LSP (`vscode-html-language-server`) |
| `css-lsp` | CSS LSP (`vscode-css-language-server`) |
| `emmet-language-server` | Emmet abbreviations |
| `gofumpt`, `goimports` | Go formatters |
| `omnisharp` / `fsautocomplete` | C# / F# LSP |
| `prettier`, `prettierd` | Prettier formatter, and its daemon |
| `golangci-lint` | Go linter (errcheck, unused, …) |
| `dockerfile-language-server` | Dockerfile LSP (`docker-langserver`) |
| `hadolint` | Dockerfile linter, with shellcheck over `RUN` bodies |
| `gomodifytags` | Add/remove struct tags (`:GoTagAdd`) |
| `gotests` | Generate table-driven tests (`:GoTests`) |
| `csharpier`, `fantomas` | C# / F# formatters |
| `stylua`, `shfmt` | Lua and shell formatters |

## Treesitter Parsers

Installed automatically on first start, see `ensure_installed` in
`lua/plugins/treesitter.lua` plus the per-stack files — 38 in total: bash, c,
c_sharp, css, diff, dockerfile, fsharp, gitignore, go, gomod, gosum, gotmpl,
gowork, graphql, html, htmldjango, http, javascript, jsdoc, json, lua, luadoc,
luap, markdown, markdown_inline, printf, python, query, regex, scss, sql, toml,
tsx, typescript, vim, vimdoc, xml, yaml.

`dtd` also appears in `:checkhealth vim.treesitter`; it is pulled in as a
dependency of the xml parser rather than requested here. There is no `jsonc`
parser — jsonc files are highlighted by the `json` one, and no `env` parser
either: `.env` falls back to Neovim's own `syntax/env.vim`, which is why it is
the one filetype here without treesitter highlighting.

Two filetypes borrow another language's parser through
`vim.treesitter.language.register`, because a compound or renamed filetype has
no parser of its own: `gohtmltmpl` → `gotmpl` (`lua/plugins/go.lua`) and
`markdown.mdx` → `markdown` (`lua/plugins/nextjs.lua`). Without that the
FileType hook in `treesitter.lua` sees `get_lang()` return nil and never starts
highlighting. Each of those filetypes also needs its own entry wherever the
config matches a filetype exactly — `formatters_by_ft` in `formatting.lua` and
the FileType autocmds in `autocmds.lua` — since neither does dot-splitting.
