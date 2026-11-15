# Dokumentasi Neovide Setup & Integrasi

Panduan konfigurasi GUI [Neovide](https://neovide.dev/) untuk Neovim, mencakup solusi kompatibilitas `noice.nvim`, pemilihan font (Iosevka), modul konfigurasi `lua/config/neovide.lua`, dan fitur animasi penuh.

---

## Daftar Isi

1. [Kompatibilitas noice.nvim & ext_messages](#1-kompatibilitas-noicenvim--ext_messages)
2. [File Konfigurasi Neovide (`neovide.toml` & Symlink)](#2-file-konfigurasi-neovide-neovidetoml--symlink)
3. [Modul Konfigurasi Neovim (`lua/config/neovide.lua`)](#3-modul-konfigurasi-neovim-luaconfigneovidelua)
4. [Font Iosevka](#4-font-iosevka)
5. [Fitur Full Animasi & VFX Kursor](#5-fitur-full-animasi--vfx-kursor)
6. [Keybindings Khusus Neovide](#6-keybindings-khusus-neovide)

---

## 1. Kompatibilitas noice.nvim & ext_messages

### Masalah
Pada Neovide **0.17+**, terdapat fitur `startup-message-capture` yang aktif secara default. Fitur ini melakukan attach Neovide ke Neovim dengan protokol `ext_messages` dan `ext_cmdline` sebelum grid pertama dirender.

Ketika `noice.nvim` dimuat, plugin mendeteksi GUI telah mengklaim `ext_messages` dan memunculkan notifikasi/error:
> *"You're using a GUI that uses ext_messages. Noice can't work when the GUI has ext_messages enabled."*

### Solusi
Matikan `startup-message-capture` pada konfigurasi Neovide (`neovide.toml` / `~/.config/neovide/config.toml`):

```toml
startup-message-capture = false
```

---

## 2. File Konfigurasi Neovide (`neovide.toml` & Symlink)

File konfigurasi Neovide disimpan langsung di dalam repository ini:
* **File di repo:** `~/.config/nvim/neovide.toml`

Secara default, Neovide membaca konfigurasi dari lokasi standar OS:
* **Linux / macOS:** `~/.config/neovide/config.toml`
* **Windows:** `%APPDATA%\neovide\config.toml`

### Cara Membuat Symlink:
* **Linux / macOS:**
  ```bash
  mkdir -p ~/.config/neovide
  ln -sf ~/.config/nvim/neovide.toml ~/.config/neovide/config.toml
  ```
* **Windows (PowerShell):**
  ```powershell
  New-Item -ItemType SymbolicLink -Path "$env:APPDATA\neovide\config.toml" -Target "$env:LOCALAPPDATA\nvim\neovide.toml"
  ```

Isi file [neovide.toml](../neovide.toml):
```toml
# Wajib dinonaktifkan agar tidak bentrok dengan noice.nvim
startup-message-capture = false

# Vsync aktif untuk animasi mulus tanpa screen tearing
vsync = true

# Lepas proses Neovide dari shell saat dijalankan dari terminal (neovide .)
fork = true
```

---

## 3. Modul Konfigurasi Neovim (`lua/config/neovide.lua`)

Semua pengaturan GUI Neovide dikelompokkan rapi di file [lua/config/neovide.lua](../lua/config/neovide.lua). Modul ini memiliki *early return* (`if not vim.g.neovide then return end`), sehingga **beban 0ms** saat Neovim dijalankan di terminal.

---

## 4. Font Iosevka

Font diatur secara otomatis ke **Iosevka Nerd Font Mono** saat membuka Neovide:
```lua
vim.opt.guifont = "Iosevka Nerd Font Mono:h11"
```

* Di terminal: Neovim tetap menggunakan font terminal Anda (atau JetBrains Mono).
* Di Neovide: Otomatis menggunakan `Iosevka Nerd Font Mono:h11`.

---

## 5. Fitur Full Animasi & Kenyamanan

Dikonfigurasi untuk pengalaman visual yang sangat halus, sinematik, dan nyaman digunakan jangka panjang:

| Opsi | Nilai | Penjelasan |
|---|---|---|
| `neovide_cursor_animation_length` | `0.13` | Transisi kursor halus dan sinematik saat lompat baris/kata |
| `neovide_cursor_short_animation_length` | `0.04` | Kursor instan tanpa lag saat mengetik karakter berdekatan |
| `neovide_cursor_trail_size` | `0.6` | Jejak kursor yang jelas saat berpindah |
| `neovide_cursor_vfx_mode` | `"railgun"` | Efek laser energi partikel dinamis |
| `neovide_cursor_smooth_blink` | `true` | Efek kedip kursor memudar lembut (*fade-in / fade-out*) |
| `neovide_cursor_unfocused_outline_width` | `0.12` | Kursor berubah jadi garis tepi rapi saat Neovide kehilangan fokus |
| `neovide_hide_mouse_when_typing` | `true` | Kursor mouse otomatis sembunyi saat mengetik (tidak menutupi teks) |
| `neovide_scroll_animation_length` | `0.25` | GPU smooth scroll murni tanpa stutter (menggantikan `snacks.scroll` di GUI) |
| `neovide_position_animation_length` | `0.15` | Animasi meluncur halus saat membuka/mengubah ukuran window split |
| `neovide_floating_corner_radius` | `8.0` | Sudut melengkung anti-aliased modern pada popup & floating window |
| `neovide_floating_shadow` | `true` | Bayangan lembut pada floating window |
| `neovide_padding_*` | Top/Bot: 8, L/R: 12 | Ruang padding tepi window agar teks tidak menempel ke border OS |
| `neovide_refresh_rate` | `144` | Render hingga 144 FPS saat kursor aktif bergerak |
| `neovide_refresh_rate_idle` | `5` | Turun ke 5 FPS saat diam (sangat hemat baterai & GPU) |

---

## 6. Keybindings Khusus Neovide

| Key | Mode | Aksi |
|---|---|---|
| `<leader>uv` | Normal | **Cycle Cursor VFX** (ganti efek railgun/torpedo/pixiedust/dll) |
| `<C-=>` | Normal / Visual | **Zoom In** (perbesar ukuran tampilan) |
| `<C-->` | Normal / Visual | **Zoom Out** (perkecil ukuran tampilan) |
| `<C-0>` | Normal / Visual | **Reset Zoom** (kembali ke skala 1.0) |
| `<F11>` | Normal | **Toggle Fullscreen** |
| `<C-S-v>` | Normal, Visual, Insert, Command | **Paste dari system clipboard** |
