# Dokumentasi Tmux Configuration

Dokumentasi lengkap untuk konfigurasi tmux dengan integrasi Neovim dan tema Monokai Pro.

## Daftar Isi

- [Instalasi](#instalasi)
- [Konfigurasi Dasar](#konfigurasi-dasar)
- [Key Bindings](#key-bindings)
- [Perintah Umum](#perintah-umum)
- [Copy Mode](#copy-mode)
- [Neovim Integration](#neovim-integration)
- [Tips & Tricks](#tips--tricks)

---

## Instalasi

### 1. Install tmux

```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux

# Arch Linux
sudo pacman -S tmux
```

### 2. Setup Konfigurasi

File konfigurasi terletak di `~/.config/nvim/tmux.conf`. Symlink ke home directory:

```bash
ln -s ~/.config/nvim/tmux.conf ~/.tmux.conf
```

### 3. Dependencies untuk Clipboard

```bash
# Ubuntu/Debian
sudo apt install xclip

# macOS (sudah include default)
```

---

## Konfigurasi Dasar

### Prefix Key

Prefix menggunakan `Ctrl+b` (default) untuk menghindari konflik dengan increment Neovim (`Ctrl+a`).

```
Prefix: Ctrl+b
```

### Pengaturan Umum

| Pengaturan | Nilai | Keterangan |
|------------|-------|------------|
| `base-index` | 1 | Window dan pane dimulai dari 1 |
| `escape-time` | 10ms | Delay untuk escape sequences |
| `history-limit` | 50000 | Baris history yang disimpan |
| `mouse` | on | Mouse support enabled |
| `default-terminal` | tmux-256color | Terminal dengan 256 warna |

---

## Key Bindings

### Window Management

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + c` | Buat window baru |
| `Prefix + n` | Window berikutnya |
| `Prefix + p` | Window sebelumnya |
| `Prefix + <` | Swap window ke kiri |
| `Prefix + >` | Swap window ke kanan |
| `Prefix + ,` | Rename window |
| `Prefix + &` | Tutup window |

### Pane Management

#### Split Panes

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + \|` | Split vertical (kiri-kanan) |
| `Prefix + -` | Split horizontal (atas-bawah) |

#### Navigasi Pane (Vim-style)

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + h` | Pindah ke pane kiri |
| `Prefix + j` | Pindah ke pane bawah |
| `Prefix + k` | Pindah ke pane atas |
| `Prefix + l` | Pindah ke pane kanan |

#### Switch / Swap Pane

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + {` | Tukar posisi dengan pane sebelumnya |
| `Prefix + }` | Tukar posisi dengan pane berikutnya |
| `Prefix + o` | Rotate semua pane dalam window |

Semua repeatable (bisa ditekan berulang tanpa mengulang prefix).

#### Toggle Show Active Pane

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + Space` | Tampilkan nomor/indikator pane (aktif disorot ungu) |
| `Prefix + z` | Toggle zoom (fullscreen) pane aktif |

Indikator pane tampil selama 2 detik (`display-panes-time 2000`), pane aktif berwarna `#ab9df2` dan pane lain `#727072`.

#### Resize Pane — Height & Width (Vim-style, repeatable)

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + H` | Resize width ke kiri (5 unit) |
| `Prefix + J` | Resize height ke bawah (5 unit) |
| `Prefix + K` | Resize height ke atas (5 unit) |
| `Prefix + L` | Resize width ke kanan (5 unit) |
| `Prefix + ←/↓/↑/→` | Resize halus (2 unit) |
| `Prefix + Shift+←/↓/↑/→` | Resize besar (10 unit) |
| `Prefix + =` | Ratakan pane horizontal |
| `Prefix + +` | Ratakan pane vertical |

### Session Management

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + d` | Detach session |
| `Prefix + s` | List semua session |
| `Prefix + $` | Rename session |

### Configuration

| Shortcut | Fungsi |
|----------|--------|
| `Prefix + r` | Reload konfigurasi |

---

## Perintah Umum

### Session Commands

```bash
# Start session baru
tmux new -s nama_session

# Attach ke session
tmux attach -t nama_session

# List semua session
tmux ls

# Kill session
tmux kill-session -t nama_session

# Switch session (dalam tmux)
Prefix + s
```

### Window Commands

```bash
# List windows
Prefix + w

# Move window
:move-window -t target_session:window_number

# Find window
Prefix + f
```

### Pane Commands

```bash
# Zoom pane (fullscreen toggle)
Prefix + z

# Break pane ke window baru
Prefix + !

# Join pane dari window lain
:join-pane -s source_window -t target_window
```

---

## Copy Mode

Copy mode menggunakan vi-style key bindings.

### Masuk Copy Mode

```
Prefix + [
```

### Navigasi dalam Copy Mode

| Key | Fungsi |
|-----|--------|
| `h/j/k/l` | Navigasi kiri/bawah/atas/kanan |
| `w/b` | Maju/mundur per kata |
| `0/$` | Awal/akhir baris |
| `g/G` | Awal/akhir buffer |
| `Ctrl+u/d` | Scroll up/down setengah halaman |
| `Ctrl+b/f` | Scroll up/down satu halaman penuh |

### Copy Operations

| Key | Fungsi |
|-----|--------|
| `v` | Mulai seleksi (visual mode) |
| `y` | Copy seleksi dan keluar |
| `Escape` | Cancel seleksi |

### Paste

```
Prefix + ]
```

---

## Neovim Integration

Konfigurasi ini dioptimalkan untuk penggunaan dengan Neovim.

### True Color Support

```bash
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```

### Clipboard Integration

Copy dari tmux otomatis masuk ke system clipboard menggunakan `xclip`.

```bash
# Copy dengan y
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"

# Copy dengan mouse drag
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard"
```

### Escape Time

Escape time diset ke 10ms untuk respons yang lebih cepat saat menggunakan Neovim.

```bash
set -sg escape-time 10
```

---

## Tips & Tricks

### 1. Quick Pane Swap

Gunakan `Prefix + z` untuk zoom pane ke fullscreen. Tekan lagi untuk kembali ke layout normal.

### 2. Synchronize Panes

Untuk mengetik di semua pane sekaligus:

```bash
:setw synchronize-panes on
```

Matikan dengan:

```bash
:setw synchronize-panes off
```

### 3. Copy Mode dengan Mouse

Mouse sudah enabled. Anda bisa:
- Click untuk switch pane
- Drag untuk select text (otomatis masuk copy mode)
- Scroll untuk melihat history

### 4. Session Persistence

Gunakan `tmuxinator` atau `tmux-resurrect` untuk save/restore session:

```bash
# Install tmux-resurrect
# Tambahkan ke tmux.conf:
set -g @plugin 'tmux-plugins/tmux-resurrect'
```

### 5. Status Bar Customization

Status bar menggunakan tema Monokai Pro dengan rounded separators. Anda bisa customize di bagian:

```bash
# Left status
set -g status-left "..."

# Right status
set -g status-right "..."
```

### 6. Debugging

Untuk melihat semua bindings:

```bash
Prefix + ?
```

Untuk melihat options:

```bash
:show-options -g
```

---

## Troubleshooting

### Warna tidak tampil dengan benar

Pastikan terminal support true color:

```bash
echo $TERM
# Harus: tmux-256color atau xterm-256color
```

### Clipboard tidak bekerja

Install `xclip`:

```bash
sudo apt install xclip
```

Test manual:

```bash
echo "test" | xclip -selection clipboard
```

### Mouse tidak bekerja

Check konfigurasi:

```bash
tmux show-options -g | grep mouse
# Harus: mouse on
```

---

## Referensi

- [Tmux Manual](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Monokai Pro Theme](https://monokai.pro/)

---

**Catatan**: Dokumentasi ini dibuat untuk konfigurasi tmux di `~/.config/nvim/tmux.conf`. Update dokumentasi ini jika ada perubahan konfigurasi.
