# 🚀 Personal Neovim Configuration

A modern, high-performance, modular Neovim configuration built on top of [lazy.nvim](https://github.com/folke/lazy.nvim) for Neovim **0.12+**. 

Engineered for full-stack development across 5 core technology stacks:
- **.NET (C#)**
- **Go (Fiber)**
- **Python (Django)**
- **Angular**
- **Next.js (React / TypeScript)**

---

## Quick Start

1. Install the core tools in [System Requirements & Global Tools](docs/REQUIREMENTS.md).
2. Clone this repository to `~/.config/nvim`.
3. Start `nvim`. On its first launch the configuration clones `lazy.nvim` and
   installs the declared plugins and Mason-managed tools.
4. Run `:Lazy` to inspect or update plugins and `:Mason` to inspect language
   tools. Use `:checkhealth` if a provider, executable, or integration is not
   working as expected.

The optional companion tools (`lazygit`, `lazydocker`, and the OpenCode CLI)
remain opt-in; install them when you want to use their corresponding shortcuts.

---

## 📚 Documentation & Guides

| Guide | Description |
|---|---|
| [System Requirements & Global Tools](docs/REQUIREMENTS.md) | Host OS packages, language SDKs, and CLI companion tools |
| [Keymaps Reference](docs/KEYMAPS.md) | Complete keybinding index, chords, and conflict notes (Leader: `;`) |
| [Plugins List](docs/PLUGINS.md) | Complete inventory of installed plugins and their roles |
| [Config Structure](docs/STRUCTURE.md) | Architectural layout of `lua/config/` and modular `lua/plugins/` |
| [Commands Reference](docs/COMMANDS.md) | Built-in commands, workspaces, dadbod, and snacks commands |
| [.NET Setup](docs/DOTNET_SETUP.md) | OmniSharp, Roslyn analyzers, CSharpier, netcoredbg, and neotest-dotnet |
| [Angular Setup](docs/ANGULAR_SETUP.md) | `@angular/language-server`, root gating, template styling, auto-tagging |
| [Django Setup](docs/DJANGO_SETUP.md) | basedpyright, django-stubs, djls, djlint, and virtualenv management |
| [Go Fiber Setup](docs/GO_FIBER.md) | gopls, gofumpt, gotmpl templates, delve DAP, and neotest-golang |
| [Monorepo Setup](docs/MONOREPO_SETUP.md) | Django API + Next.js frontend workflow and `:MonorepoSetup` |
| [Tmux Integration](docs/TMUX.md) | Window navigation and tmux workflow |
| [Neovide Integration](docs/NEOVIDE.md) | Neovide GUI setup, font configuration, and noice compatibility |

---

## 🛠️ Stack Parity Overview

| Feature | .NET (C#) | Go Fiber | Django | Angular | Next.js |
|---|---|---|---|---|---|
| **LSP** | `omnisharp` (Roslyn) | `gopls` | `basedpyright` + `djls` | `angularls` | `vtsls` + `tailwindcss` |
| **Formatting** | `csharpier` (4 spasi) | `gofumpt` + `goimports` | `ruff` + `djlint` | `prettierd` | `biome` / `prettierd` |
| **Linting** | Roslyn Analyzers | `golangci-lint` | `ruff` + `mypy` | ESLint | `eslint-lsp` |
| **Debugging (DAP)** | `netcoredbg` | `delve` | `debugpy` | `js-debug` | `js-debug` (Node/Chrome) |
| **Testing** | `neotest-dotnet` | `neotest-golang` | `neotest-python` | `neotest-vitest` | `neotest-vitest`/`jest` |
| **Templates** | Razor / XML | `gohtmltmpl` | `htmldjango` (auto) | Component HTML | TSX / JSX |

---

## ⚡ Essential Keymaps Cheat Sheet

Leader key is mapped to **`;`** (semicolon).

### 🔍 Find & Search
| Key | Action |
|---|---|
| `;fg` | **Global live grep** across all files in workspace (or visual selection) |
| `;ff` / `;fF` | Find files (project root / current working directory) |
| `;fr` / `;fR` | Recent files |
| `;fb` | Active open buffers |
| `;fe` / `;e` | File explorer tree (Snacks) |

### 💡 Code & LSP Intelligence
| Key | Action |
|---|---|
| `gd` | Go to definition (Snacks picker with preview) |
| `grr` | Find references |
| `gri` | Find implementations |
| `gh` | Hover documentation & type signature |
| `gs` | Signature help |
| `E` | Show diagnostics / error detail under cursor |
| `]d` / `[d` | Jump to next / previous diagnostic |
| `;ca` / `<space>a` | Code action / Quick Fix (normal & visual mode) |
| `;cr` / `<space>r` | Rename symbol workspace-wide |
| `;cf` / `<space>f` | Format buffer via `conform.nvim` |
| `;xx` / `;xX` | Toggle Trouble diagnostics panel (all / current buffer) |

### ✍️ Editing Experience
| Key | Action |
|---|---|
| `jj` | Exit insert mode to normal mode |
| `<C-s>` / `;w` | Save file |
| `;q` | Close current buffer safely |
| `<C-d>` / `<C-u>` | Scroll down / up and center cursor (`zz`) |
| `<A-j>` / `<A-k>` | Move line(s) down / up |
| `<A-S-j>` / `<A-S-k>` | Duplicate line(s) down / up |
| `;p` (in visual) | Paste over selection without overwriting clipboard |
| `J` | Join lines while keeping cursor position intact |
| `s` / `S` | Jump anywhere on screen via `flash.nvim` |
| `ys{motion}{char}` | Add delimiter surrounding word (e.g. `ysiw"`) |
| `cs{target}{replacement}` | Change delimiter surrounding word (e.g. `cs"'` or `cst<p>`) |
| `ds{target}` | Delete surrounding delimiter (e.g. `ds"` or `dst`) |
| `gS` | Toggle single-line ↔ multi-line arguments/props/structs (`mini.splitjoin`) |
| `;uc` | Toggle sticky context headers (`treesitter-context`) |
| `co` / `ct` / `cb` | Git merge conflicts: choose ours / theirs / both (`git-conflict.nvim`) |

### 🚀 Git, Terminal, Testing & Debugging
| Key | Action |
|---|---|
| `;gg` | Open LazyGit floating terminal |
| `;gb` | Toggle inline Git blame line |
| `;gd` | Open Git diff view (`diffview.nvim`) |
| `;t` / `<A-t>` | Toggle floating terminal |
| `;Th` / `<A-s>` | Split terminal horizontal (bottom 35%) |
| `;Tv` / `<A-v>` | Split terminal vertical (right 40%) |
| `;tf` | Split terminal in current file's directory |
| `;ts` / `<S-CR>` | Send current line / selection to terminal |
| `;tr` | Run current file in split terminal |
| `;ty` | Copy all terminal output to clipboard |
| `<A-i>` | Quick focus toggle between editor and terminal |
| `<A-u>` / `<A-d>` | Safe scroll terminal up / down without interrupting running agents |
| `;Nr` | Run nearest unit test under cursor (`neotest`) |
| `;Nf` | Run all unit tests in the current file |
| `;Ns` | Toggle test summary sidebar |
| `;Dc` | Start / continue debugging session (`nvim-dap`) |
| `;Db` | Toggle breakpoint on current line |
| `;Du` | Toggle DAP UI (variables, watches, call stack) |
| `;au` | Toggle Database UI (`vim-dadbod-ui`) |
| `;hh` | Send HTTP request under cursor (`kulala.nvim`) |

---

## 📦 Requirements

- **Neovim >= 0.12.0**
- **Git**
- **Ripgrep (`rg`)** and **fd**
- A **Nerd Font** (recommended: *JetBrains Mono Nerd Font*)
- Language toolchains: `.NET SDK`, `Go`, `Python 3`, `Node.js` (v20+)
