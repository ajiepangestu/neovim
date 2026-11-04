# .NET (C#) Setup

Everything lives in `lua/plugins/dotnet.lua`.

## What you get

| Piece | Tool | Description |
|-------|------|-------------|
| LSP | `omnisharp` | Roslyn analyzers, organize imports, auto-import completion |
| Formatter | `csharpier` | Idiomatic C# formatter via `conform.nvim` (format-on-save) |
| Parser | `c_sharp` | Highlighting, folding, and textobjects via Treesitter |
| Debugger | `coreclr` (`netcoredbg`) | Breakpoints, stepping, locals, REPL via `nvim-dap` |
| Test runner | `neotest-dotnet` | xUnit, NUnit, MSTest runner via `neotest` |

## LSP & Code Actions

OmniSharp is configured with:
- `enable_roslyn_analyzers = true`: Warnings and suggestions from Roslyn analyzers (e.g. IDE0005 unused usings, CA rules).
- `organize_imports_on_format = true`: Cleans up and sorts `using` directives.
- `enable_import_completion = true`: Auto-suggests types from unimported namespaces and adds the `using` statement on selection.

Keymaps:
- `gd`: Go to definition
- `grr`: References (Snacks picker)
- `<space>a`: Code action / fix suggestions
- `<space>r`: Rename symbol
- `<space>f` / `<leader>cf`: Format file with CSharpier

## Debugging (DAP)

Debugging is powered by `netcoredbg` through `nvim-dap`:
- `<leader>Dc`: Start debug session (prompts for the compiled DLL path in `bin/Debug/netX.0/...` or attaches to a running process).
- `<leader>Db`: Toggle breakpoint on the current line.
- `<leader>Du`: Toggle DAP UI (variables, watches, call stack, breakpoints).
- `<leader>Dt`: Terminate session.

## Testing (neotest)

Unit tests in xUnit, NUnit, or MSTest projects can be run directly from Neovim:
- `<leader>Nr`: Run the nearest test method under the cursor.
- `<leader>Nf`: Run all tests in the current file.
- `<leader>Na`: Run entire test suite (`dotnet test`).
- `<leader>Ns`: Toggle test summary sidebar.
- `<leader>Nd`: Debug nearest test under cursor with breakpoints.
