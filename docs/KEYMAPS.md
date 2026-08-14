# Keymaps Reference

Leader key: `;`

## General

| Key         | Mode       | Action                                                |
| ----------- | ---------- | ----------------------------------------------------- |
| `,,`        | n          | Repeat f/t forward                                    |
| `<leader>d` | n          | Close current buffer (opens explorer if none left)    |
| `<leader>q` | n          | Close all buffers and open explorer (never quits nvim)|
| `<leader>qq`| n          | Quit all                                              |
| `<leader>w` | n, x, s    | Save (not insert mode — see Known Keymap Conflicts)   |
| `<C-s>`     | n, i, x, s | Save (works in insert mode too)                       |
| `<C-S-f>`   | n, x       | Format buffer                                         |
| `<leader>cf`| n, x       | Format buffer                                         |
| `<esc>`     | i, n, s    | Clear search highlight / stop snippet                 |
| `j` / `k`   | n, x       | Move by display line when no count is given           |
| `<A-j>` / `<A-k>` | n, i, v | Move line(s) down / up                            |
| `gco` / `gcO` | n        | Add comment below / above                             |
| `s` / `S`   | n, x, o    | Flash jump / flash treesitter                         |
| `r`         | o          | Remote flash (operate on a distant target)            |
| `R`         | o, x       | Flash treesitter search                               |
| `n` / `N`   | n, x, o    | Next / previous search result, always in the same direction and unfolded |
| `<` / `>`   | x          | Indent left / right and keep the selection            |
| `,` `.` `;` | i          | Undo break-points (see Known Keymap Conflicts)        |
| `<leader>fn`| n          | New file                                              |
| `<leader>.` | n          | Toggle scratch buffer                                 |

## Buffers & Tabs

| Key            | Mode | Action                  |
| -------------- | ---- | ----------------------- |
| `<S-h>` / `[b` | n    | Previous buffer         |
| `<S-l>` / `]b` | n    | Next buffer             |
| `<leader>bb`   | n    | Switch to other buffer  |
| `<leader>bo`   | n    | Close other buffers     |
| `<leader><tab><tab>` | n | New tab              |
| `<leader><tab>]` / `[` | n | Next / previous tab |
| `<leader><tab>d` / `o` | n | Close tab / other tabs |

## Workspaces

Multi-root workspaces, saved to disk. See `lua/config/workspace.lua` and the
`:Workspace*` commands in `docs/COMMANDS.md`.

| Key          | Mode | Action                       |
| ------------ | ---- | ---------------------------- |
| `<leader>ws` | n    | Save workspace               |
| `<leader>wo` | n    | Open workspace               |
| `<leader>wa` | n    | Add folder to workspace      |
| `<leader>wr` | n    | Remove folder from workspace |
| `<leader>wd` | n    | Delete workspace             |
| `<leader>wc` | n    | Show current workspace       |

## Sessions (persistence.nvim)

| Key          | Mode | Action                        |
| ------------ | ---- | ----------------------------- |
| `<leader>qs` | n    | Restore session               |
| `<leader>ql` | n    | Restore last session          |
| `<leader>qS` | n    | Select session                |
| `<leader>qd` | n    | Don't save the current session|
| `<leader>qq` | n    | Quit all                      |

## Window Navigation

| Key    | Mode | Action               |
| ------ | ---- | -------------------- |
| `<C-h>` | n    | Move to left window  |
| `<C-j>` | n    | Move to window below |
| `<C-k>` | n    | Move to window above |
| `<C-l>` | n    | Move to right window |
| `<leader>[` | n    | Split horizontal     |
| `<leader>]` | n    | Split vertical       |
| `<C-Up>` / `<C-Down>` | n | Resize height |
| `<C-Left>` / `<C-Right>` | n | Resize width |

## LSP (Custom)

Neovim 0.12 ships `grr`, `gri`, `grt`, `gra`, `grn`, `grx` and `K`. The three
navigation ones are overridden to use the snacks picker: a single result jumps
straight there, several results open a list with a preview (like VS Code).

| Key          | Mode | Action                    |
| ------------ | ---- | ------------------------- |
| `gd`         | n    | Go to definition (picker) |
| `grr`        | n    | References (picker)       |
| `gri`        | n    | Implementations (picker)  |
| `grt`        | n    | Type definition (picker)  |
| `gh`         | n    | Hover                     |
| `gs`         | n    | Signature help            |
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
| `<leader>li` | n    | LSP info (checkhealth)    |
| `<leader>cv` | n    | Select Python virtualenv  |
| `<leader>xx` | n    | Diagnostics (Trouble)     |
| `<leader>cs` | n    | Symbols (Trouble)         |
| `]t` / `[t`  | n    | Next / previous todo comment |

### TypeScript / Next.js (vtsls buffers)

| Key          | Mode | Action                    |
| ------------ | ---- | ------------------------- |
| `gD`         | n    | Goto source definition    |
| `<leader>cM` | n    | Add missing imports       |
| `<leader>cD` | n    | Fix all diagnostics       |
| `<leader>co` | n    | Organize imports          |
| `<leader>cE` | n    | ESLint fix all (in eslint buffers) |

## Picker (snacks)

| Key                | Mode | Action                          |
| ------------------ | ---- | ------------------------------- |
| `<leader><space>`  | n    | Find files (root dir)           |
| `<leader>/`        | n    | Grep (root dir)                 |
| `<leader>,`        | n    | Buffers                         |
| `<leader>:`        | n    | Command history                 |
| `<leader>n`        | n    | Notification history            |
| `<leader>ff` / `fF`| n    | Find files (root dir / cwd)     |
| `<leader>fg`       | n    | Find files (git-files)          |
| `<leader>fr` / `fR`| n    | Recent files (all / cwd)        |
| `<leader>fc`       | n    | Find config file                |
| `<leader>fe` / `fE`| n    | Explorer (root dir / cwd)       |
| `<leader>sb`       | n    | Buffer lines                    |
| `<leader>sd` / `sD`| n    | Diagnostics (all / buffer)      |
| `<leader>sh`       | n    | Help pages                      |
| `<leader>sk`       | n    | Keymaps                         |
| `<leader>ss` / `sS`| n    | LSP symbols (document / workspace) |
| `<leader>su`       | n    | Undo tree                       |
| `<leader>sR`       | n    | Resume last picker              |
| `<leader>st`       | n    | Todo comments                   |
| `<leader>fb`       | n    | Buffers                         |
| `<leader>S`        | n    | Select scratch buffer           |
| `<leader>s"`       | n    | Registers                       |
| `<leader>s/`       | n    | Search history                  |
| `<leader>sc` / `sC`| n    | Command history / commands      |
| `<leader>sa`       | n    | Autocmds                        |
| `<leader>si`       | n    | Icons                           |
| `<leader>sj`       | n    | Jumps                           |
| `<leader>sm`       | n    | Marks                           |
| `<leader>sM`       | n    | Man pages                       |
| `<leader>sp`       | n    | Search plugin spec              |
| `<leader>sq` / `sl`| n    | Quickfix list / location list   |
| `<leader>snh`      | n    | Noice history                   |
| `<leader>snl`      | n    | Noice last message              |
| `<leader>snd`      | n    | Dismiss all Noice messages      |
| `<leader>uC`       | n    | Colorschemes                    |
| `<a-c>`            | picker | Toggle between root dir and cwd |
| `<a-t>`            | picker | Send results to Trouble       |

## UI Toggles

| Key          | Action                               |
| ------------ | ------------------------------------ |
| `<leader>uf` | Toggle format on save (global)       |
| `<leader>uF` | Toggle format on save (buffer)       |
| `<leader>ud` | Toggle diagnostics                   |
| `<leader>ul` | Toggle line numbers                  |
| `<leader>uh` | Toggle inlay hints                   |
| `<leader>uw` | Toggle wrap                          |
| `<leader>us` | Toggle spelling                      |
| `<leader>ug` | Toggle indent guides                 |
| `<leader>uz` | Toggle zen mode                      |
| `<leader>uZ` | Toggle zoom                          |
| `<leader>ui` | Inspect position (highlights)        |
| `<leader>uA` | Toggle tabline                       |
| `<leader>uT` | Toggle treesitter highlight          |
| `<leader>un` | Dismiss all notifications            |
| `<leader>ur` | Redraw / clear hlsearch / diff update|

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
| `<leader>pm` | n    | Open Mason UI             |
| `<leader>e`  | n    | Toggle file explorer      |
| `<leader>t`  | n, t | Toggle terminal           |
| `<leader>th` | n, t | Terminal split horizontal |
| `<leader>tv` | n, t | Terminal split vertical   |
| `<leader>gg` | n    | Open LazyGit              |
| `<leader>?`  | n    | Buffer keymaps (which-key)|
| `<leader>K`  | n    | Keywordprg (`K` on the word under the cursor) |

## OpenCode

| Key          | Mode | Action                                  |
| ------------ | ---- | --------------------------------------- |
| `<C-.>`      | n, t | Toggle the OpenCode terminal            |
| `<leader>oa` | n, x | Ask OpenCode about the range            |
| `<leader>os` | n, x | Select an OpenCode prompt               |
| `go`         | n, x | Operator: append a motion/range to OpenCode |
| `goo`        | n    | Append the current line to OpenCode      |
| `<C-S-u>` / `<C-S-d>` | n | Scroll the OpenCode session half a page up / down |

`go` shadows the built-in `go` ("go to byte N"), and is also the prefix of
`goo`. Since `go` is an operator it waits for a motion anyway, so the extra
`timeoutlen` wait is not noticeable.

## Lists (Trouble & quickfix)

| Key          | Mode | Action                  |
| ------------ | ---- | ----------------------- |
| `<leader>xx` | n    | Diagnostics (Trouble)   |
| `<leader>xt` | n    | Todo (Trouble)          |
| `<leader>xq` | n    | Quickfix list           |
| `<leader>xl` | n    | Location list           |
| `<leader>xQ` | n    | Quickfix list (Trouble) |
| `<leader>xL` | n    | Location list (Trouble) |

## Git

| Key          | Mode | Action              |
| ------------ | ---- | ------------------- |
| `<leader>gb` | n    | Toggle git blame    |
| `<leader>go` | n    | Open commit URL     |
| `<leader>gc` | n    | Copy commit URL     |
| `<leader>gf` | n    | Copy file URL       |
| `<leader>gd` | n    | Open diff view      |
| `<leader>gh` | n    | File history        |
| `<leader>gs` | n    | Git status picker   |
| `<leader>gS` | n    | Git stash picker    |
| `<leader>gl` | n    | Git log             |
| `<leader>gL` | n    | Git log (current file) |
| `<leader>gB` | n, x | Git browse (open in browser) |
| `<leader>gY` | n, x | Git browse (copy url) |
| `]h` / `[h`  | n    | Next / previous hunk |
| `<leader>ghs` / `ghr` | n, x | Stage / reset hunk |
| `<leader>ghS` / `ghR` | n | Stage / reset buffer |
| `<leader>ghp`| n    | Preview hunk inline |
| `<leader>ghd`| n    | Diff this file      |

## Completion (blink.cmp, insert mode)

Uses the `enter` preset.

| Key                 | Action                                      |
| ------------------- | ------------------------------------------- |
| `<CR>`              | Accept                                      |
| `<C-y>`             | Select and accept                           |
| `<C-space>`         | Show menu / toggle documentation            |
| `<C-n>` / `<C-p>`   | Next / previous item                        |
| `<Down>` / `<Up>`   | Next / previous item                        |
| `<C-f>` / `<C-b>`   | Scroll documentation down / up              |
| `<C-e>`             | Cancel                                      |
| `<C-k>`             | Toggle signature window                     |
| `<Tab>` / `<S-Tab>` | Next / previous snippet placeholder         |

In the command line, blink uses its `cmdline` preset (`<Tab>` completes,
`<C-n>`/`<C-p>` and `<Left>`/`<Right>` cycle). noice adds one more:

| Key      | Mode | Action                                            |
| -------- | ---- | ------------------------------------------------- |
| `<S-CR>` | c    | Redirect the command line output to a split        |

## Better Escape

| Key  | Mode | Action           |
| ---- | ---- | ---------------- |
| `jj` | i    | Exit insert mode |

## Emmet

Abbreviations are expanded through `emmet_language_server`: type `div.card` and
accept it from the completion menu (`<CR>`). Works in html, css, scss, jsx/tsx,
htmldjango and gohtmltmpl.

| Key          | Mode | Action                          |
| ------------ | ---- | ------------------------------- |
| `<leader>ce` | n, v | Wrap selection with abbreviation |

## Known Keymap Conflicts

These are deliberate, not bugs. They are listed so the behaviour is not
surprising.

### Keys that are also a prefix

`timeoutlen` is 300ms (`lua/config/options.lua`). When a key is *both* a
complete mapping and the prefix of longer ones, Neovim cannot know which you
meant until you either type the next key or the timeout expires — so the bare
key fires ~300ms late.

Each is kept as-is because the bare key is the one worth having on the short
keystroke. The table below lists what actually occupies each prefix, so you can
judge whether a sub-key is worth keeping.

| Bare key | Delayed action | Held by | Those sub-keys do |
| -------- | -------------- | ------- | ----------------- |
| `<leader>w` | Save (normal mode) | `ws` `wo` `wa` `wr` `wd` `wc` | save workspace, open workspace, add folder to workspace, remove folder from workspace, delete workspace, show current workspace |
| `<leader>q` | Close all buffers + open explorer | `qq` `qs` `qS` `ql` `qd` | quit all, restore session, select session, restore last session, stop saving current session |
| `<leader>t` | Toggle terminal | `th` `tv` | terminal in a horizontal split, terminal in a vertical split |
| `<leader>gh` | Diffview file history | `ghs` `ghr` `ghS` `ghR` `ghp` `ghd` | stage hunk, reset hunk, stage buffer, reset buffer, preview hunk inline, diff this file |

### Why `<leader>w` is not mapped in insert mode

The leader is `;`, and `;` is *also* mapped in insert mode as an undo
break-point (`;<C-g>u`, next to `,` and `.` in `lua/config/keymaps/core.lua`).
Mapping `<leader>w` in insert mode would therefore make every typed semicolon a
prefix and delay it by `timeoutlen` — noticeable in TypeScript, JavaScript and
C#, where semicolons are typed constantly.

So `<leader>w` is `n`, `x`, `s` only. Use `<C-s>` to save from insert mode; it
does the same thing and is not a prefix. This is a deviation from LazyVim, where
the leader is `<space>` and the clash never arises.

`<space>` is in the same situation inside LSP buffers: it is a prefix for
`<space>a` `<space>f` `<space>r` `<space>s` `<space>d` (code action, format,
rename, workspace symbol, document symbol), so plain `<space>` — which moves the
cursor right — also fires ~300ms late there.

Workarounds that need no config change:

- **Save without the delay**: use `<C-s>` — mapped to the same thing in `n`,
  `i`, `x` and `s`, and it is not a prefix.
- **Force any bare key immediately**: press `<Esc>` after it. `;w<Esc>` saves at
  once, because `<Esc>` is a complete mapping and never a prefix, so Neovim
  stops waiting. Here it also clears the search highlight, which is harmless.

### `<C-k>` is mode-dependent

| Mode | Action | Set by |
| ---- | ------ | ------ |
| n | Window up | `lua/config/keymaps/core.lua` |
| t (terminal) | Window up | snacks terminal (`lua/plugins/snacks.lua`) |
| i | Toggle signature window, else fall through | blink.cmp `enter` preset |

Signature help in normal mode is on `gs`, *not* `<C-k>` — a buffer-local
`<C-k>` would shadow window-up in every buffer with an LSP attached, which is
most of them. `gs` overrides the built-in "sleep" command, which nothing uses.

### `<S-h>` / `<S-l>` are literally `H` / `L`

Neovim normalises `<S-h>` to `H`, so the buffer-switching maps replace the
built-in `H` (move to the top of the screen) and `L` (bottom of the screen)
everywhere. `M` (middle) is untouched. Use `gg`/`G`, or `zt`/`zz`/`zb` to
scroll, if you relied on those motions.

### Diagnostics float on `E`

`E` normally moves to the end of the current/next WORD. It is remapped to
`vim.diagnostic.open_float`, but buffer-locally in LSP buffers only — so the
motion still works in every other buffer, and `e` (word instead of WORD) is
untouched everywhere.
