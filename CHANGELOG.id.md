# Changelog

Perubahan Flip30 didokumentasikan di sini. Bahasa Inggris adalah sumbernya; Bahasa Indonesia (file ini) adalah terjemahan yang selalu selaras.

## v1.6.0

Musik prosedural pada saat main.

### Fitur baru

- **Musik prosedural.** Loop generatif 10 detik yang dimainkan saat main, dengan pitch berubah sesuai aturan aktif (KONTROL TERBALIK sedikit rendah, WAKTU LAMBAT jauh lebih rendah, SEMUA 2X CEPAT dikali.). Tanpa pengaturan, langsung terasa sekitar aturanmu.

## v1.5.0

Dua aturan baru, overlay debug in-game, dan perbaikan tampilan combo.

### Fitur baru

- **Lima belas aturan.** Dua aturan baru: `HANTU` (objek jadi tembus pandang, tag vision) dan `WAKTU LAMBAT` (semua merayap setengah kecepatan, tag speed).
- **Overlay debug.** `love . --debug` menampilkan FPS, draw call, canvas switch, objek aktif, dan memori tekstur. Tekan I untuk menampilkannya di dalam game.

### Perbaikan bug

- **Tampilan combo.** Menu dan layar game over menampilkan streak mentah sebagai "COMBO TERBAIK xN"; sekarang menampilkan multiplier yang benar (streak 4 adalah x2, bukan x4).

## v1.4.0

Statistik sepanjang waktu, makanan keemasan, dan banyak kejutan kecil di atas v1.3.0.

### Fitur baru

- **Panel statistik sepanjang waktu.** Tekan TAB di menu untuk melihat total main, total waktu bertahan, total skor, total makanan, skor terbaik, dan combo terbaik. Stats disimpan secara lokal dan terakumulasi di setiap run.
- **Makanan keemasan.** Drop langka (7%) bernilai +50 poin, bebas dari TUKAR WARNA.
- **Combo milestone.** Popup "COMBO x2 / x3 / x4 / x5" muncul saat streak melewati ambang tertentu.
- **Denyut jantung.** Vignet merah berdenyut saat nyawa tinggal satu.
- **Angka skor bertahap.** Counter skor memudahkan angka ke harga aslinya, tidak patah mendadak.

### Perbaikan bug

- **Kilat merah nyangkut di game over.** Umur flash sekarang terus meluruh setelah run berakhir, jadi layar game over tidak pernah kemerahan permanen.

## v1.3.0

Tiga belas aturan, aturan ukuran player, gravitasi turbulen, dan bug fix dari audit mendalam.

### Fitur baru

- **Tiga belas aturan.** Tiga aturan baru: `BESAR` (player menjadi lebar 72 px, tag control), `KECIL` (player menjadi 22 px, tag control), dan `GRAVITASI TURBULEN` (arah jatuh berganti setiap 2 detik, tag gravity).
- **Penghitung total main.** Menu utama sekarang menampilkan berapa kali kamu sudah bermain secara total.

### Perbaikan bug

- **Player size bocor.** Ukuran player dikembalikan ke default 40 x 40 saat main lagi, supaya BESAR dan KECIL tidak meneruskan efeknya ke sesi berikutnya.
- **Popup pinalti escape.** Musuh yang lolos ke sisi atas saat aturan gravitasi naik menampilkan popup di atas, bukan di bawah.

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
