# Changelog

Perubahan Flip30 didokumentasikan di sini. Bahasa Inggris adalah sumbernya; Bahasa Indonesia (file ini) adalah terjemahan yang selalu selaras.

## Unreleased

### Improvements

- **Dokumen mengikuti satu standar penulisan.** README dan CHANGELOG sekarang tersedia dalam Bahasa Inggris dan Bahasa Indonesia secara selaras, release notes memuat checksum SHA-256 dan daftar toolchain, dan wording di seluruh repository dirapikan menjadi kalimat pendek dan lugas.

## v1.0.0

Rilis publik pertama Flip30.

### New features

- **Gameplay inti.** Arena 800x600 dengan player sticky note 40x40 lewat A/D atau tombol panah, makanan bernilai +10 dan musuh mengurangi 1 nyawa, dan kurva kesulitan yang menaikkan kecepatan jatuh dan laju spawn seiring waktu.
- **Sistem aturan.** Aturan adalah satu file Lua di `rules/`, berganti otomatis setiap 30 detik dengan banner dua detik dan slow motion 0.3x. Aturan yang sama tidak pernah aktif dua kali berturut-turut, dan aturan dengan tag yang sama tidak pernah aktif bersamaan.
- **Delapan aturan.** KONTROL TERBALIK, GRAVITASI MATI, GRAVITASI NAIK, MUSUH JADI POIN, TUKAR WARNA, LAYAR GELAP, SEMUA 2X CEPAT, TIDAK BISA BERHENTI.
- **Skor terbaik.** Disimpan secara lokal di `highscore.txt`, dengan perayaan "REKOR BARU!" saat rekor terpecahkan.
- **State game.** Menu, playing, dan game over, dengan hearts, progress bar tipis untuk timer aturan, popup skor melayang, screen shake, dan kilat merah saat kena hit.
- **SFX disintesis.** Catch, hit, swap, gameover, record, dan select, dihasilkan saat load time; nol file audio.
- **Mod tersandbox.** Aturan tambahan di folder `rules/` direktori save berjalan tanpa akses `os`, `io`, atau `love`. Contoh mod disediakan (`examples/rules/gerak_pelan.lua`).
- **Mode artwork deterministik.** `love . --screenshot out.png --frames N [--force-rule "NAME"]` menghasilkan capture yang dipakai di repository ini.
- **Open source.** Lisensi MIT.

### Improvements

- **Kanvas letterbox.** Virtual canvas 800x600 di-letterbox dan di-scale ke ukuran jendela apa pun.
- **Test suite headless.** 193 assertion di bawah LuaJIT, dijalankan di CI bersama pengecekan format StyLua.
