if not vim.g.neovide then
	return
end

-- Font khusus Neovide (Iosevka Nerd Font)
vim.opt.guifont = "Iosevka Nerd Font Mono:h11"

--------------------------------------------------------------------------------
-- 1. Full Animasi Kursor & Efek Visual (Sangat Halus & Memanjakan Mata)
--------------------------------------------------------------------------------
-- Durasi animasi perpindahan kursor saat lompat baris/kata (0.13s memberikan transisi mulus sinematik)
vim.g.neovide_cursor_animation_length = 0.13

-- Animasi kursor cepat saat mengetik karakter berdekatan (0.04s agar mengetik terasa instan tanpa lag)
vim.g.neovide_cursor_short_animation_length = 0.04

-- Jejak kursor (trail) saat berpindah
vim.g.neovide_cursor_trail_size = 0.6
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_smooth_blink = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = true

-- Bentuk kursor bergaris luar (outline) saat Neovide kehilangan fokus (misal buka browser)
vim.g.neovide_cursor_unfocused_outline_width = 0.12

-- Sembunyikan mouse otomatis saat mengetik agar tidak menutupi kode
vim.g.neovide_hide_mouse_when_typing = true

-- Efek partikel kursor (Railgun: laser partikel dinamis yang menghubungkan posisi kursor)
vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_cursor_vfx_opacity = 200.0
vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
vim.g.neovide_cursor_vfx_particle_density = 7.0
vim.g.neovide_cursor_vfx_particle_speed = 10.0

--------------------------------------------------------------------------------
-- 2. Animasi Scrolling & Transisi Window/Split
--------------------------------------------------------------------------------
-- Animasi scrolling halus saat lompat halaman (<C-d>, <C-u>, atau mouse wheel)
vim.g.neovide_scroll_animation_length = 0.25
vim.g.neovide_scroll_animation_far_lines = 1

-- Animasi pergeseran posisi window saat membuat split (<C-w>v / <C-w>s) atau resize
vim.g.neovide_position_animation_length = 0.15

--------------------------------------------------------------------------------
-- 3. Window & Tampilan
--------------------------------------------------------------------------------
-- Padding tepi jendela agar teks tidak menempel ke border OS
vim.g.neovide_padding_top = 8
vim.g.neovide_padding_bottom = 8
vim.g.neovide_padding_left = 12
vim.g.neovide_padding_right = 12

-- Mengingat posisi dan ukuran window terakhir
vim.g.neovide_remember_window_size = true

-- Sudut melengkung halus pada floating window (LSP hover, Snacks picker, Trouble)
vim.g.neovide_floating_corner_radius = 8.0

-- Bayangan lembut dan blur pada floating window
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

--------------------------------------------------------------------------------
-- 4. Performa & Refresh Rate
--------------------------------------------------------------------------------
-- Refresh rate tinggi saat aktif untuk animasi super mulus (144 Hz)
-- dan otomatis turun ke 5 FPS saat diam agar hemat baterai/GPU
vim.g.neovide_refresh_rate = 144
vim.g.neovide_refresh_rate_idle = 5

--------------------------------------------------------------------------------
-- 5. Keymaps Khusus Neovide
--------------------------------------------------------------------------------
-- Zoom in / out / reset interaktif (<C-=>, <C-->, <C-0>)
local change_scale = function(delta)
	vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) * delta
end

vim.keymap.set({ "n", "v" }, "<C-=>", function()
	change_scale(1.1)
end, { desc = "Neovide: Zoom in" })

vim.keymap.set({ "n", "v" }, "<C-->", function()
	change_scale(1 / 1.1)
end, { desc = "Neovide: Zoom out" })

vim.keymap.set({ "n", "v" }, "<C-0>", function()
	vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide: Reset zoom" })

-- Toggle fullscreen (<F11>)
vim.keymap.set("n", "<F11>", function()
	vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "Neovide: Toggle fullscreen" })

-- Paste dari clipboard sistem di GUI (<C-S-v>)
vim.keymap.set({ "n", "v" }, "<C-S-v>", '"+P', { desc = "Neovide: Paste clipboard" })
vim.keymap.set("i", "<C-S-v>", '<ESC>"+pa', { desc = "Neovide: Paste clipboard" })
vim.keymap.set("c", "<C-S-v>", "<C-R>+", { desc = "Neovide: Paste clipboard" })
