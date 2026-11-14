# Flip30: PRD dan Master Prompt

Game arcade Lua (LÖVE2D) di mana aturan main berganti acak tiap 30 detik.

## Bagian 1: PRD

## 1. Ringkasan

**Flip30** adalah game arcade 2D singkat. Pemain mengendalikan sebuah kotak di arena, menangkap objek yang jatuh untuk skor, dan harus bertahan selama mungkin. Tiap 30 detik, satu aturan main diganti secara acak (kontrol terbalik, gravitasi mati, dst). Pemain harus cepat beradaptasi sebelum kalah.

- **Platform:** PC (Windows/Linux/macOS) via LÖVE 11.x. Stretch goal: Android dan web (love.js)
- **Bahasa:** Lua 5.1/LuaJIT
- **Distribusi:** itch.io
- **Tujuan:** portofolio, mudah dimainkan siapa saja, desain mudah diperluas (modding)

## 2. Tujuan dan Non-Tujuan

**Tujuan**

- Game yang bisa dimainkan dalam 10 detik pertama tanpa tutorial
- Sistem aturan modular: menambah aturan baru = menambah satu blok tabel Lua
- Satu sesi bermain berkisar 1 sampai 5 menit
- Kode rapi dan terbaca, layak dipamerkan di GitHub

**Non-Tujuan (MVP)**

- Multiplayer, akun online, leaderboard online
- Aset grafis kompleks (cukup bentuk geometris + partikel)
- Level atau cerita

## 3. Target Pengguna

- Pemain kasual yang suka game arcade singkat
- Teman dan komunitas yang menerima link itch.io
- Developer lain yang ingin bikin aturan sendiri (modder)

## 4. Core Gameplay Loop

1. Game mulai dengan aturan default
2. Objek jatuh dari atas: **makanan** (+skor) dan **musuh** (-nyawa)
3. Pemain menggerakkan kotak untuk menangkap makanan dan menghindari musuh
4. Tiap 30 detik: banner pengumuman, lalu aturan lama di-`revert()`, aturan baru di-`apply()`
5. Nyawa habis, muncul layar Game Over, skor tersimpan jika rekor baru
6. Tekan tombol untuk main lagi

## 5. Fitur MVP

| ID | Fitur | Deskripsi | Prioritas |
| --- | --- | --- | --- |
| F1 | Player | Kotak dengan gerak kiri/kanan (A/D atau panah), batas arena | P0 |
| F2 | Objek jatuh | Spawner untuk makanan dan musuh dengan kecepatan dan interval yang dapat diatur | P0 |
| F3 | Skor dan nyawa | Skor naik saat tangkap makanan, nyawa 3, HUD sederhana | P0 |
| F4 | Sistem aturan | Tiap aturan adalah tabel `{ name, apply, revert }`, rule manager memilih acak tanpa mengulang aturan yang sama berturut-turut | P0 |
| F5 | Timer 30 detik | Countdown di HUD, memicu pergantian aturan | P0 |
| F6 | Banner aturan baru | Teks besar (contoh: "KONTROL TERBALIK!") muncul 2 detik dengan animasi | P0 |
| F7 | High score | Disimpan lewat `love.filesystem` (file `highscore.txt`) | P0 |
| F8 | State game | Menu, Playing, GameOver | P0 |

## 6. Daftar Aturan Awal (5 aturan wajib untuk MVP)

| # | Nama | Efek |
| --- | --- | --- |
| 1 | KONTROL TERBALIK | Kiri jadi kanan, kanan jadi kiri |
| 2 | GRAVITASI MATI | Objek melayang pelan (gravity 0, kecepatan jatuh dasar kecil) |
| 3 | GRAVITASI NAIK | Objek jatuh dari bawah ke atas |
| 4 | MUSUH JADI POIN | Menyentuh musuh memberi poin, menghindar mengurangi poin |
| 5 | TUKAR WARNA | Warna makanan dan musuh ditukar (menipu mata) |

**Aturan cadangan (tahap polish):** LAYAR GELAP (hanya sekitar player terlihat), SEMUA 2X CEPAT, TIDAK BISA BERHENTI (player selalu bergerak).

## 7. Fitur Lanjutan (Pasca-MVP)

- **Dua aturan aktif sekaligus** pada tingkat sulit (setelah 2 menit)
- **Mode modding:** file `.lua` di folder `rules/` otomatis dimuat
- **Audio dinamis:** SFX dan musik berubah mengikuti aturan aktif
- **Build Android** (LÖVE Android) dan **web** (love.js)
- **Kesulitan progresif:** spawn rate dan kecepatan naik seiring waktu

## 8. Persyaratan Non-Fungsional

- 60 FPS stabil di laptop standar
- Resolusi dasar 800x600, bisa di-scale
- Ukuran build di bawah 20 MB
- Tidak ada dependensi eksternal selain LÖVE (library kecil boleh di-vendor)
- Revert aturan harus selalu mengembalikan state ke kondisi bersih (tidak boleh ada efek bocor)

## 9. Arsitektur Teknis

```
flip30/
  main.lua
  conf.lua
  src/
    game.lua          -- state machine dan loop utama
    player.lua
    spawner.lua       -- objek jatuh
    world.lua         -- gravity, speed multiplier, flags global
    rulemanager.lua   -- pilih, apply, revert aturan
    ui.lua            -- HUD, banner, menu, game over
    storage.lua       -- high score via love.filesystem
    modloader.lua     -- (pasca-MVP) muat rules/*.lua
    particles.lua     -- (polish)
  rules/
    reverse_controls.lua
    gravity_off.lua
    gravity_up.lua
    enemy_points.lua
    swap_colors.lua
  assets/
    fonts/ sfx/ music/
  README.md
```

**Kontrak aturan (rule contract):**

```lua
return {
  name = "KONTROL TERBALIK",
  apply  = function(ctx) ctx.player.dir = -1 end,
  revert = function(ctx) ctx.player.dir = 1 end,
}
```

`ctx` berisi referensi ke `player`, `world`, `spawner`, `ui`. Aturan opsional boleh punya `update(ctx, dt)` dan `draw(ctx)` (untuk efek seperti layar gelap).

## 10. Kriteria Sukses

- Pemain baru paham cara main tanpa instruksi tertulis
- Semua 5 aturan awal bisa apply dan revert tanpa bug state
- Menambah aturan baru hanya butuh 1 file/blok tanpa mengubah kode inti
- High score bertahan setelah game ditutup
- Terbit di itch.io dengan halaman, screenshot, dan GIF gameplay

## 11. Roadmap

| Hari | Target |
| --- | --- |
| 1 | Player, objek jatuh, skor, nyawa, state game |
| 2 | Rule manager, timer 30 detik, 5 aturan pertama |
| 3 | Polish: partikel, SFX, animasi banner, screen shake |
| 4 | Mode modding, README, build, rilis itch.io |

## 12. Risiko

| Risiko | Mitigasi |
| --- | --- |
| Revert aturan meninggalkan efek sisa | Semua parameter lewat `world`/`player` dengan nilai default terpusat, ada fungsi `resetToDefaults()` |
| Dua aturan bentrok (contoh: dua-duanya mengubah gravity) | Tandai `tags` per aturan, rule manager menolak kombinasi tag yang sama |
| Mod berbahaya dari folder rules/ | Muat dengan `pcall` dan environment terbatas (`setfenv`), tanpa akses `os`/`io` |
| Scope membengkak | Patuhi urutan P0 dulu, fitur lanjutan hanya setelah MVP jalan |

---

## Bagian 2: Master Prompt untuk AI Coding Agent

Salin semua teks di bawah ke agent (Claude Code, Cursor, dll).

```
Kamu adalah senior game developer Lua yang ahli LÖVE2D (versi 11.x). Bangun game "Flip30" dari nol sesuai spesifikasi ini. Kerjakan secara otonom, bertahap, dan pastikan game selalu bisa dijalankan (`love .`) di setiap tahap.

## KONSEP
Game arcade 2D singkat. Pemain mengendalikan kotak di bawah layar, menangkap objek jatuh. Setiap 30 detik, satu ATURAN MAIN diganti secara acak (misal kontrol terbalik, gravitasi mati). Pemain harus beradaptasi cepat sebelum kehabisan nyawa. Gaya visual minimalis geometris, neon di latar gelap.

## TECH STACK
- Lua + LÖVE 11.x, tanpa dependensi eksternal
- Resolusi 800x600, window title "Flip30"
- Semua file bahasa Lua, kode modular per file di folder src/
- Gaya kode: snake_case untuk variabel dan fungsi, komentar singkat berbahasa Inggris, tanpa global yang tidak perlu

## STRUKTUR FOLDER
flip30/
  main.lua, conf.lua
  src/ game.lua, player.lua, spawner.lua, world.lua, rulemanager.lua, ui.lua, storage.lua, modloader.lua, particles.lua
  rules/ reverse_controls.lua, gravity_off.lua, gravity_up.lua, enemy_points.lua, swap_colors.lua
  assets/ fonts/ sfx/ music/
  README.md

## GAMEPLAY
- State: menu, playing, gameover (tekan Enter/Space untuk mulai dan restart)
- Player: kotak 40x40, gerak kiri/kanan dengan A/D atau panah, tertahan batas layar, kecepatan 400 px/detik
- Objek jatuh: dua tipe, FOOD (hijau, +10 skor saat ditangkap) dan ENEMY (merah, -1 nyawa saat tersentuh). Spawn di posisi x acak, interval awal 0.8 detik, kecepatan jatuh awal 200 px/detik, dan naik pelan seiring waktu
- Nyawa awal 3. Skor ditampilkan di HUD bersama nyawa, timer pergantian aturan, dan nama aturan aktif
- Makanan yang lolos tidak mengurangi apa pun (kecuali aturan tertentu menentukan lain)

## SISTEM ATURAN (INTI PROJECT)
Setiap aturan adalah satu file di rules/ yang me-return tabel:

  return {
    name = "KONTROL TERBALIK",
    tags = { "control" },            -- untuk mencegah bentrok antar aturan
    apply  = function(ctx) ... end,
    revert = function(ctx) ... end,
    update = function(ctx, dt) end,  -- opsional
    draw   = function(ctx) end,      -- opsional, digambar di atas arena
  }

`ctx` = { player, world, spawner, ui }.

RuleManager wajib:
1. Memuat semua aturan dari rules/ otomatis (love.filesystem.getDirectoryItems + require)
2. Tiap 30 detik: revert aturan aktif, pilih aturan baru secara acak (tidak sama dengan sebelumnya), tampilkan banner, apply aturan baru
3. Menyediakan resetToDefaults() yang mengembalikan semua parameter world dan player ke nilai awal, dipanggil saat game over dan restart
4. Menggunakan pcall saat memuat dan menjalankan aturan agar mod yang rusak tidak membuat game crash (log error ke console, lewati aturan itu)
5. Siap mendukung N aturan aktif sekaligus (parameter max_active, default 1), menolak kombinasi aturan dengan tag yang sama

Implementasikan 5 aturan:
1. KONTROL TERBALIK: arah gerak player dikali -1
2. GRAVITASI MATI: objek melayang sangat pelan
3. GRAVITASI NAIK: objek bergerak dari bawah ke atas (spawn di bawah)
4. MUSUH JADI POIN: menyentuh musuh +15 skor, musuh yang lolos ke batas layar -5 skor (tidak mengurangi nyawa)
5. TUKAR WARNA: warna makanan dan musuh ditukar, perilaku asli tetap

Aturan tambahan jika waktu cukup: LAYAR GELAP (stencil atau lingkaran cahaya di sekitar player), SEMUA 2X CEPAT (world.speed_mul = 2), TIDAK BISA BERHENTI (player selalu bergerak ke arah terakhir).

## UI DAN JUICE
- Banner besar di tengah layar saat aturan berganti (contoh "KONTROL TERBALIK!"), animasi scale-in dan fade-out selama sekitar 2 detik, game tetap berjalan atau melambat sebentar (slow motion 0.3x selama banner)
- Progress bar tipis di atas layar untuk sisa waktu menuju pergantian aturan
- Partikel saat menangkap makanan dan saat kena musuh, screen shake ringan saat kena musuh
- SFX sederhana (boleh dibangkitkan lewat love.audio dan SoundData prosedural jika tidak ada file)

## PENYIMPANAN
storage.lua menyimpan dan memuat high score di love.filesystem (file highscore.txt), tampilkan di menu dan game over, beri tanda "NEW RECORD!" jika terpecahkan. Tangani file yang belum ada atau korup tanpa crash.

## MODDING (tahap akhir)
modloader.lua memuat file .lua tambahan dari folder rules/ di save directory (love.filesystem.getSaveDirectory) selain folder bawaan. Jalankan dengan pcall dan environment terbatas (setfenv) tanpa akses os, io, dan love.filesystem langsung. Dokumentasikan format aturan di README beserta satu contoh mod.

## CARA KERJA
Kerjakan berurutan, jalankan dan verifikasi tiap tahap sebelum lanjut:
1. Skeleton project, state game, player, spawner, skor, nyawa
2. RuleManager, timer 30 detik, 5 aturan, banner
3. Storage high score, menu dan game over
4. Polish: partikel, SFX, shake, progress bar
5. Modding, README (cara main, cara bikin aturan, cara build), build .love

Setiap akhir tahap: jelaskan singkat apa yang sudah jadi, cara menjalankan, dan sarankan commit message dengan format Conventional Commits.

## KRITERIA SELESAI
- `love .` berjalan tanpa error, 60 FPS
- Semua aturan bisa apply dan revert tanpa efek tersisa (uji dengan memicu tiap aturan berulang kali)
- Menambah aturan baru hanya dengan menambah satu file di rules/
- High score bertahan antar sesi
- Kode terstruktur sesuai folder di atas dan README lengkap

## BATASAN
- Jangan tambah dependensi atau aset eksternal berat
- Jangan ubah kontrak aturan (name, tags, apply, revert, update, draw)
- Jika ada keputusan ambigu, pilih opsi paling sederhana dan catat di README
```
