# Changelog

Perubahan Flip30 didokumentasikan di sini. Bahasa Inggris adalah sumbernya; Bahasa Indonesia (file ini) adalah terjemahan yang selalu selaras.

## v1.2.0

Upgrade terbesar sejauh ini: combo scoring, dua aturan baru, dan presentasi paling kaya.

### Fitur baru

- **Streak combo.** Setiap 4 tangkapan berturut-turut menaikkan multiplier skor sebesar satu level, maksimal x5. Kena musuh meresetnya. Combo terbaik sepanjang masa disimpan secara lokal dan ditampilkan di layar game over.
- **Mute.** Tekan M untuk membisukan semua SFX, di mana pun.
- **Sepuluh aturan.** Dua aturan baru: `HUJAN` (laju spawn dua kali lipat, tag `spawn`) dan `SKOR GANDA` (semua poin dikali dua, tag `scoring`). Setiap aturan sekarang membawa deskripsi Indonesia yang tampil di bawah teks banner.
- **Mata sticky note.** Mata player mengikuti arah gerak, dengan bob idle dan squash and stretch saat kena hit.
- **Tampilan lebih kaya.** Arena gradasi yang di-prerender dengan dot grid dan vignette, glow halo additive, objek jatuh berputar atau bergoyang, HUD chip (skor, nyawa, pill aturan, timer bertahan, chip combo, chip mute, chip 2x di fase dua aturan), siluet jatuh di belakang menu, banner dengan garis deskripsi dan border neon, dan pitch SFX swap berbeda per tag.

### Peningkatan

- **Peralatan rilis.** `scripts/build.ps1` membaca format changelog terkini, menghasilkan release notes dwi-bahasa Inggris dan Indonesia dengan Install / Update dan tabel SHA-256, dan menyertakan dokumen Indonesia ke dalam build Windows.
- **Test headless.** 227 assertion termasuk cakupan eskalasi dua aturan dan combo multiplier.

## v1.1.0

Rilis kedua Flip30, fokus pada feel, antarmuka, dan fase late game.

### Fitur baru

- **Dua aturan di menit kedua.** Setelah menit ke-2, dua aturan aktif bersamaan; keduanya tidak boleh punya tag yang sama, dan HUD menampilkan chip "2x ATURAN".
- **Pause.** Tekan P untuk menjeda aksi dan P lagi untuk lanjut; dunia, timer aturan, dan banner semuanya membeku.
- **Mata sticky note.** Mata player mengikuti arah gerak, dengan bob idle dan squash and stretch saat kena hit.
- **Trauma shake dan hit-stop.** Hit musuh memicu screen shake berbasis trauma dan freeze hit-stop 60 ms.
- **Tampilan lebih kaya.** Palet warna brand, arena gradasi, dot grid, vignette, glow halo untuk objek, HUD chip (skor, nyawa, BERTAHAN), siluet jatuh di belakang menu, dan pitch SFX swap berbeda per tag.

### Peningkatan

- **Peralatan rilis.** `scripts/build.ps1` membaca format changelog terkini, menghasilkan release notes dwi-bahasa Inggris dan Indonesia dengan Install / Update dan tabel SHA-256, dan menyertakan dokumen Indonesia ke dalam build Windows.
- **Test headless.** 197 assertion termasuk cakupan eskalasi dua aturan.

## v1.0.0

Rilis publik pertama Flip30.

### Fitur baru

- **Gameplay inti.** Arena 800x600 dengan player sticky note 40x40 lewat A/D atau tombol panah, makanan bernilai +10 dan musuh mengurangi 1 nyawa, dan kurva kesulitan yang menaikkan kecepatan jatuh dan laju spawn seiring waktu.
- **Sistem aturan.** Aturan adalah satu file Lua di `rules/`, berganti otomatis setiap 30 detik dengan banner dua detik dan slow motion 0.3x. Aturan yang sama tidak pernah aktif dua kali berturut-turut, dan aturan dengan tag yang sama tidak pernah aktif bersamaan.
- **Delapan aturan.** KONTROL TERBALIK, GRAVITASI MATI, GRAVITASI NAIK, MUSUH JADI POIN, TUKAR WARNA, LAYAR GELAP, SEMUA 2X CEPAT, TIDAK BISA BERHENTI.
- **Skor terbaik.** Disimpan secara lokal di `highscore.txt`, dengan perayaan "REKOR BARU!" saat rekor terpecahkan.
- **State game.** Menu, playing, dan game over, dengan hearts, progress bar tipis untuk timer aturan, popup skor melayang, screen shake, dan kilat merah saat kena hit.
- **SFX disintesis.** Catch, hit, swap, gameover, record, dan select, dihasilkan saat load time; nol file audio.
- **Mod tersandbox.** Aturan tambahan di folder `rules/` direktori save berjalan tanpa akses `os`, `io`, atau `love`. Contoh mod disediakan (`examples/rules/gerak_pelan.lua`).
- **Mode artwork deterministik.** `love . --screenshot out.png --frames N [--force-rule "NAME"]` menghasilkan capture yang dipakai di repository ini.
- **Open source.** Lisensi MIT.

### Peningkatan

- **Kanvas letterbox.** Virtual canvas 800x600 di-letterbox dan di-scale ke ukuran jendela apa pun.
- **Test suite headless.** 193 assertion di bawah LuaJIT, dijalankan di CI bersama pengecekan format StyLua.
