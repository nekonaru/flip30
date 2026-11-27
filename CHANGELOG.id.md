# Changelog

Perubahan Flip30 didokumentasikan di sini. Bahasa Inggris adalah sumbernya; Bahasa Indonesia (file ini) adalah terjemahan yang selalu selaras.

## v4.0.0

Update gerak dan UX.

### Fitur baru

- **Design system.** Token bersama untuk warna, jarak, radius, elevasi dan gerak.
- **Animasi.** Tween, easing, stagger, wipe layar, squash dan spring. Semua durasi mengikuti gerak minimal.
- **Onboarding.** Panduan pertama tiga langkah, H untuk ulang.
- **Rekap.** Grade, grafik skor, combo puncak dan aturan dilihat, tekan V.
- **Sistem toast.** Notifikasi sementara untuk pencapaian dan rekor.
- **Editor tema.** Warna aksen dan preset HUD dengan N.
- **Mod manager.** Aktif dan nonaktifkan mod dengan B.
- **Foto mode.** Bekukan dengan J dan simpan PNG dengan K.

## v3.0.0

Update arena: kampanye, bos, multiplayer, hazard dan craft aturan.

### Fitur baru

- **Kampanye.** Delapan bab dengan target skor, bertahan dan bos, dipilih dengan F9.
- **Bos.** Lima pola dengan HP, kecepatan dan transparansi berbeda.
- **Multiplayer.** Co-op, versus dan hot-seat dengan F11.
- **Crafting.** Gabungkan kondisi dan efek jadi aturan yang bisa dibalik dengan F12.
- **Skin.** Delapan skin dengan F10.
- **Hazard.** Laser, arena menyusut dan blackout.
- **Papan skor dan turnamen.** Sepuluh terbaik harian dengan L, bracket delapan pemain dengan T.
- **Dokumen desain akhir.** `docs/GDD.md` dan `docs/GDD.id.md`.

## v2.0.0

Update Flip30 terbesar: tujuh mode, tiga puluh aturan, varian musuh, item, kemampuan, progresi dan replay.

### Fitur baru

- **Tujuh mode.** Klasik, Blitz, Marathon, Zen, Chaos, Harian dan Boss Rush, dipilih dengan F1.
- **Tiga puluh aturan.** Tiga belas aturan baru dan sistem draft di Chaos, pilih satu dari tiga.
- **Varian musuh.** Cepat, zirah, pembelah, phantom dan bom terbuka seiring waktu.
- **Item dan kemampuan.** Magnet, shield, freeze, double, nyawa, skip aturan, bersihkan layar. Dash dengan Shift dan focus dengan Space.
- **Progresi.** XP, level, 20 pencapaian, tiga profil, toko koin, ekspor/import.
- **Layar baru.** Pengaturan, codex, pencapaian, profil dan replay, plus seed harian dan rekam input untuk hantu.
- **Script build web** dan metadata itch.io.

## v1.8.0

Lima skor terbaik, menu pause lebih lengkap, dan perbaikan dari audit source mendalam.

### Fitur baru

- **Lima skor terbaik.** `scores.txt` menyimpan lima skor terbaikmu; panel statistik di menu menampilkan semuanya.
- **Aksi menu pause.** R main lagi, Q / ESC kembali ke menu, P lanjut, M bisu.

### Perbaikan bug

- **Mute dari menu tidak kena musik.** Tombol M sekarang memanggil `game.setMute` di semua state.
- **Panel statistik menampilkan streak mentah sebagai multiplier.** Sekarang menampilkan multiplier yang didapat (streak 4 jadi x2).
- **Source musik dibuat ulang terus.** Loop sekarang dibuat sekali dan dipakai ulang.
- **Definisi `game.setMute` ganda.** Copy mati dihapus.
- **Pitch aturan belum lengkap.** SKOR GANDA, HUJAN EMAS dan TANPA BATAS sekarang ikut mengubah musik.

## v1.7.0

Dua aturan baru, musik mengikuti aturan, dan beberapa perbaikan dari audit mendalam.

### Fitur baru

- **Tujuh belas aturan.** `TANPA BATAS` membuat player bisa lewat tepi layar, bukan berhenti. `HUJAN EMAS` melipatgandakan kemunculan makanan keemasan.
- **Musik mengikuti aturan.** Loop prosedural sekarang berubah pitch saat aturan baru aktif, dan berhenti saat keluar dari game.

### Perbaikan bug

- **Pitch SFX bocor antar-suara.** `sfx.play` sekarang mengembalikan pitch ke x1 bila tidak ada pitch, sehingga suara high-pitch dari emas tidak mengubah suara biasa.
- **Musik tidak bisa melihat aturan.** `game.ctx` sekarang membawa `rulemanager` dan `music`, sehingga manager bisa menyuruh musik berubah.

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
