# Keymaps Reference

Leader key: `;`

## General

| Key         | Mode       | Action                                                |
| ----------- | ---------- | ----------------------------------------------------- |
| `,,`        | n          | Repeat f/t forward                                    |
| `<leader>d` | n          | Close current buffer (opens explorer if none left)    |
| `<leader>q` | n          | Close all buffers and open explorer (never quits nvim)|
| `<leader>w` | n, i, x, s | Save                                                  |
| `<C-S-f>`   | n, x       | Format buffer                                         |

## Window Navigation

| Key    | Mode | Action               |
| ------ | ---- | -------------------- |
| `<C-h>` | n    | Move to left window  |
| `<C-j>` | n    | Move to window below |
| `<C-k>` | n    | Move to window above |
| `<C-l>` | n    | Move to right window |
| `<leader>[` | n    | Split horizontal     |
| `<leader>]` | n    | Split vertical       |

## LSP (Custom)

Neovim 0.12 built-in defaults (`K`, `grd`, `grD`, `gri`, `grt`, `grr`, `gra`, `grn`) are active.

| Key          | Mode | Action                    |
| ------------ | ---- | ------------------------- |
| `gd`         | n    | Go to definition          |
| `gh`         | n    | Hover                     |
| `<C-k>`      | n    | Signature help            |
| `<space>a`   | n    | Code action               |
| `<space>f`   | n    | Format buffer             |
| `<space>r`   | n    | Rename                    |
| `<space>s`   | n    | Workspace symbol          |
| `<space>d`   | n    | Document symbol           |
| `E`          | n    | Show diagnostic float     |
| `]d`         | n    | Next diagnostic           |
| `[d`         | n    | Previous diagnostic       |
| `<leader>le` | n    | Buffer diagnostics picker |
| `<leader>lE` | n    | All diagnostics picker    |

## Search

| Key          | Mode | Action                        |
| ------------ | ---- | ----------------------------- |
| `<leader>sg` | n    | Search global (Spectre)       |
| `<leader>sw` | n    | Search word under cursor      |
| `<leader>sf` | n    | Search in current file        |

### Spectre Keymaps (in search buffer)

| Key          | Action              |
| ------------ | ------------------- |
| `dd`         | Toggle item         |
| `<CR>`       | Open file           |
| `<leader>q`  | Send to quickfix    |
| `<leader>c`  | Replace command     |
| `<leader>o`  | Show options        |
| `<leader>rc` | Replace current line|
| `<leader>R`  | Replace all         |
| `<leader>v`  | Change view mode    |
| `ti`         | Toggle ignore case  |
| `th`         | Toggle hidden files |

## Plugins

| Key          | Mode | Action                    |
| ------------ | ---- | ------------------------- |
| `<leader>pl` | n    | Open Lazy UI              |
| `<leader>e`  | n    | Toggle file explorer      |
| `<leader>t`  | n, t | Toggle terminal           |
| `<leader>th` | n, t | Terminal split horizontal |
| `<leader>tv` | n, t | Terminal split vertical   |
| `<leader>gg` | n    | Open LazyGit              |

## Git

| Key          | Mode | Action              |
| ------------ | ---- | ------------------- |
| `<leader>gb` | n    | Toggle git blame    |
| `<leader>go` | n    | Open commit URL     |
| `<leader>gc` | n    | Copy commit URL     |
| `<leader>gf` | n    | Copy file URL       |
| `<leader>gd` | n    | Open diff view      |
| `<leader>gh` | n    | File history        |

## Copilot (Insert Mode)

| Key     | Action              |
| ------- | ------------------- |
| `<C-l>` | Accept suggestion   |
| `<C-j>` | Accept word         |
| `<C-k>` | Accept line         |
| `<C-]>` | Next suggestion     |
| `<C-[>` | Previous suggestion |
| `<C-\>` | Dismiss suggestion  |

## Better Escape

| Key  | Mode | Action           |
| ---- | ---- | ---------------- |
| `jj` | i    | Exit insert mode |

## Emmet

| Key     | Mode | Action                    |
| ------- | ---- | ------------------------- |
| `<C-e>` | i    | Expand emmet abbreviation |
