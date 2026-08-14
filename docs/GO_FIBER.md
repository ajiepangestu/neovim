# Go / Fiber Setup

Everything lives in `lua/plugins/go.lua`.

## What you get

| Piece | Tool |
|-------|------|
| LSP | `gopls` (gofumpt, staticcheck, unusedparams, inlay hints, codelenses) |
| Format on save | `goimports` then `gofumpt` |
| Parsers | `go`, `gomod`, `gosum`, `gowork`, `gotmpl` |
| Templates | `gohtmltmpl` filetype + gopls diagnostics + emmet + tailwind LSP |

### Which gopls gets used

`$GOBIN/gopls` (or `$GOPATH/bin/gopls`, default `~/go/bin/gopls`) is preferred
when it exists — that is the binary `go install golang.org/x/tools/gopls@latest`
produces, built with your local Go version, and the same one the VS Code Go
extension manages. Distro packages are often several releases behind: this
machine has `/usr/bin/gopls` v0.18.1 (built with go1.24.3) on `$PATH` while
`~/go/bin/gopls` is v0.23.0 (go1.26.5). Without the override, `$PATH` wins and
you silently get the older server.

Keep it current with:

```sh
go install golang.org/x/tools/gopls@latest
```

Mason only installs `gopls` when no binary is found at all. `gofumpt` and
`goimports` always come from Mason.

## Templates

Fiber's `html` view engine renders plain `.html` files containing `{{ ... }}`
actions. Those keep the `html` filetype, so emmet, the tailwind LSP and html
completions all keep working. Prettier is deliberately **skipped** for html
buffers that contain `{{` — it reflows template actions and breaks
`{{ if }}` / `{{ range }}` blocks that span tags. Such files are therefore not
formatted on save.

Files with an explicit Go template extension get the `gohtmltmpl` filetype and
treesitter highlighting from the `gotmpl` parser:

- `*.gohtml`
- `*.gotmpl`
- `*.tmpl`

So if you want template highlighting and don't mind the extension, name your
views `index.gohtml` and point Fiber at them:

```go
engine := html.New("./views", ".gohtml")
app := fiber.New(fiber.Config{Views: engine})
```

Those three extensions also get **gopls template diagnostics** — an unclosed
`{{ range }}` is reported as `unexpected EOF` with source `template`. Two
settings are needed for that, and neither works alone:

| Setting | Why |
| ------- | --- |
| `gohtmltmpl` added to gopls `filetypes` | lspconfig only lists `gotmpl`, and nothing in this config ever produces that filetype |
| `templateExtensions = { "gohtml", "gotmpl", "tmpl" }` | gopls defaults this to empty and analyses no templates at all until it is set |

Fiber's plain `.html` views are intentionally left out of `templateExtensions`:
adding `html` would make gopls treat every html file in the project as a Go
template. Those files still get emmet, tailwind and html completions — they just
do not get template diagnostics. Rename them to `.gohtml` if you want both.

## Note for mixed repos

`djls` (the Django language server) also claims the `html` filetype. It is
pinned to directories containing a `manage.py`, so it will not attach to Go
templates in a Fiber project. See `lua/plugins/django.lua`.

## Adding a linter

`golangci-lint` is not wired up. If you want it:

```lua
-- lua/plugins/go.lua
{ "mason-org/mason.nvim", opts = { ensure_installed = { "golangci-lint" } } },
{ "neovim/nvim-lspconfig", opts = { servers = { golangci_lint_ls = {} } } },
```
