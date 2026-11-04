# System Requirements & Global Tools

Panduan kebutuhan sistem, runtime bahasa, dan perkakas global (*system-level tools*) yang diperlukan agar seluruh fitur Neovim berjalan maksimal.

---

## 1. Perkakas Sistem Wajib (*Core System Tools*)

Perkakas berikut **wajib terpasang di host OS** (pada `$PATH`):

| Perkakas | Perintah Cek | Fungsi di Neovim |
|---|---|---|
| **Neovim >= 0.12.0** | `nvim --version` | Editor utama (menggunakan fitur `vim.lsp.enable`, virtual text, dll.) |
| **Git** | `git --version` | Plugin manager (`lazy.nvim`), `gitsigns`, `diffview` |
| **ripgrep (`rg`)** | `rg --version` | Mesin pencarian teks super cepat untuk `;fg` (`Snacks.picker.grep`) |
| **fd** | `fd --version` (atau `fdfind`) | Mesin pencarian file untuk `;ff` (`Snacks.picker.files`) |
| **curl / tar / unzip** | `curl --version` | Diperlukan oleh Mason untuk mengunduh dan mengekstrak binary LSP |
| **Nerd Font** | - | Rendering icon statusline, winbar, explorer, dan autocomplete (contoh: *JetBrains Mono Nerd Font*) |

### Perintah Instalasi OS:

#### Fedora / RHEL:
```bash
sudo dnf install -y neovim git ripgrep fd-find curl tar unzip
```

#### Ubuntu / Debian:
```bash
sudo apt update
sudo apt install -y git ripgrep fd-find curl tar unzip
# Di Debian/Ubuntu, buat alias symlink fd jika binary-nya bernama fdfind:
ln -s $(which fdfind) ~/.local/bin/fd
```

#### Arch Linux:
```bash
sudo pacman -S neovim git ripgrep fd curl tar unzip
```

#### macOS (Homebrew):
```bash
brew install neovim git ripgrep fd curl
```

---

## 2. Perkakas CLI Pendukung (*Recommended Companion Tools*)

Perkakas Terminal UI yang diintegrasikan langsung ke dalam Neovim:

| Perkakas | Shortcut di Neovim | Keterangan & Cara Pasang |
|---|---|---|
| **`lazygit`** | **`;gg`** | TUI Git client dalam floating window.<br>• **Fedora:** `sudo dnf install lazygit` atau `go install github.com/jesseduffield/lazygit@latest`<br>• **Ubuntu:** download dari GitHub releases atau PPA.<br>• **macOS:** `brew install lazygit` |
| **`lazydocker`** | **`;kd`** | TUI Docker container manager.<br>• Pasang via: `curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \| bash` |

---

## 3. Runtime Bahasa & SDK Global

Agar Neovim dapat menjalankan, mengompilasi, men-debug, dan menjalankan unit test proyek Anda, pastikan SDK bahasa terpasang:

### A. .NET (C#)
* **Wajib:** `.NET SDK` (versi 6.0, 7.0, 8.0, atau 9.0).
* **Perintah Cek:** `dotnet --version`
* Digunakan untuk: kompilasi proyek, `dotnet run`, dan test runner (`dotnet test` via `neotest-dotnet`).

### B. Go (Fiber)
* **Wajib:** `Go` (>= 1.21).
* **Perintah Cek:** `go version`
* **Direkomendasikan:** Pastikan `~/go/bin` sudah masuk ke `$PATH` di `~/.bashrc` atau `~/.zshrc`:
  ```bash
  export PATH="$HOME/go/bin:$PATH"
  ```

### C. Python (Django)
* **Wajib:** `python3` (>= 3.10) dan modul `venv`.
* **Perintah Cek:** `python3 --version`
* **Project Virtualenv:** Saat membuat virtual environment di proyek Django Anda:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  pip install django-stubs[compatible-mypy]
  ```

### D. Node.js (Next.js & Angular)
* **Wajib:** `Node.js` (LTS v20+) dan `npm` (atau `pnpm` / `yarn`).
* **Perintah Cek:** `node -v` dan `npm -v`
* Digunakan untuk menjalankan dev server (`npm run dev`), build Next.js / Angular, dan package manager frontend.

### E. Docker & Docker Compose
* **Wajib:** `docker` daemon dan CLI `docker compose`.
* **Perintah Cek:** `docker compose version`
* Digunakan untuk container logs (`;kl`), container ps (`;kp`), dan attach debugger.

---

## 4. Yang TIDAK Perlu Diinstal Global (Dikelola Otomatis oleh Mason)

Anda **TIDAK PERLU** mengotori sistem global dengan menjalankan perintah seperti `npm install -g` atau `pip install --break-system-packages` untuk language server atau formatter berikut. 

Seluruh perkakas di bawah ini **sudah otomatis diunduh, diisolasi, dan diperbarui oleh Mason** di `~/.local/share/nvim/mason/bin/`:

* ❌ `npm i -g @angular/language-server` *(Sudah di-handle Mason)*
* ❌ `npm i -g vtsls typescript` *(Sudah di-handle Mason)*
* ❌ `npm i -g vscode-langservers-extracted` *(HTML, CSS, JSON, ESLint di-handle Mason)*
* ❌ `npm i -g @tailwindcss/language-server` *(Sudah di-handle Mason)*
* ❌ `npm i -g prettier prettierd` *(Sudah di-handle Mason)*
* ❌ `pip install basedpyright ruff djlint` *(Sudah di-handle Mason)*
* ❌ `dotnet tool install -g csharpier` *(Sudah di-handle Mason)*
* ❌ Debugger binary (`delve`, `netcoredbg`, `js-debug-adapter`, `debugpy`) *(Sudah di-handle Mason)*
