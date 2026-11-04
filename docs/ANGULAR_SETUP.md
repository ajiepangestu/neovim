# Angular Setup

Everything lives in `lua/plugins/angular.lua`.

## What you get

| Piece | Tool | Description |
|-------|------|-------------|
| LSP | `@angular/language-server` (`angularls`) | Template diagnostics, component bindings, pipes, inline template completion |
| Formatter | `prettier` / `prettierd` | Formats `.html`, `.ts`, and `.scss` on save via `conform.nvim` |
| Auto-tag | `nvim-ts-autotag` | Auto-close and auto-rename Angular component & HTML tags |
| Color preview | `nvim-highlight-colors` | Color square previews for CSS/SCSS and Tailwind classes |
| Test runner | `neotest-vitest` / `neotest-jest` | Runs component & service unit tests directly in Neovim |

## Root Gating

`angularls` attaches **only** when an Angular project root is detected by looking for:
- `angular.json`
- `nx.json`
- `project.json`

This ensures that plain HTML, standard TypeScript, and Next.js / React projects outside of Angular remain clean and unaffected.

## Template & CSS Support

- HTML templates have full access to `angularls`, `html` language server, `emmet_language_server`, and `tailwindcss`.
- Component inline templates or external `.html` files support auto-closing tags and auto-renaming via `nvim-ts-autotag`.
- CSS / SCSS files have color swatch preview via `nvim-highlight-colors` and property validation via `cssls`.
