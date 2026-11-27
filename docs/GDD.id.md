# Flip30 v3.0: Arena - Desain Final

## Visi

Flip30 v3.0 mengubah loop arcade pemain tunggal menjadi game arena lengkap dengan kampanye, multiplayer lokal, bos, craft aturan dan progresi. Game tetap native: Lua 5.1, LÖVE 11.x, tanpa Dependensi eksternal, canvas 800x600, target 60 FPS.

## Pilar

1. **Paham dalam sepuluh detik.** Tiap mode menjelaskan target di layar pilih.
2. **Aturan diutamakan.** Tiap aturan satu file Lua dengan name, tags, hint, apply dan revert. Aturan buatan memakai kontrak yang sama.
3. **Deterministik.** Step tetap 60 Hz dan RNG bersama membuat seed serta replay bisa diulang.
4. **Progresif.** Bab, varian musuh, hazard dan bos terbuka seiring waktu.
5. **Lokal dulu.** Tanpa akun, backend maupun jaringan. Skor dan profil tetap di mesin pemain.

## Sistem

### Kampanye

Delapan bab dengan target jelas. Bab bisa mensyaratkan skor, waktu bertahan, jumlah bos atau kombinasi. Menyelesaikan bab menaikkan level profil. New Game+ mengulang kampanye dengan semua bab terbuka.

### Bos

Lima bos dengan HP, kecepatan, burst dan transparansi berbeda. Boss Rush memunculkan bos tiap dua menit. Setiap tangkapan mengurangi HP bos. Pembelah memunculkan musuh cepat saat kalah. Zirah butuh dua serangan.

### Multiplayer

Co-op memakai satu arena. Versus membagi skor dua pemain. Hot-seat bergiliran. Pemain satu memakai A/D dan Shift, pemain dua panah dan Shift kanan. Pemenang adalah skor tertinggi.

### Hazard

Laser mulai di 30 detik, arena menyusut di 90 detik, blackout di 150 detik. Laser mengurangi nyawa dan bisa dimatikan lewat opsi gerak minimal.

### Crafting

Aturan buatan menggabungkan satu kondisi dan satu efek. Efek memakai parameter world yang sama dengan aturan bawaan, sehingga apply dan revert tetap simetris. Aturan buatan langsung masuk pool.

### Progresi

XP dan level membuka skin serta aturan. Dua puluh pencapaian meliputi skor, combo, bertahan, mode, bos dan mod. Tiga profil menyimpan progres terpisah. Ekspor/import memakai file teks.

### Replay

Tiap step tetap mencatat satu frame input. Seed dan rekaman menghasilkan spawn objek serta swap aturan yang sama. Hantu pemain digambar sebagai kotak transparan. Hash verifikasi membandingkan hasil run.

## Layar

Menu, pilih mode, pengaturan, codex, pencapaian, profil, replay, kampanye, skin, multiplayer, crafting, papan skor, turnamen, toko, pause dan game over. Semua layar memakai bahasa visual chip dan panel yang sama.

## Kriteria selesai

- 395 atau lebih assertion headless lulus di LuaJIT.
- StyLua tidak melaporkan selisih.
- Soak 20.000 frame mencapai game over tanpa error.
- Bagian README Inggris dan Indonesia seimbang jumlahnya.
- Release notes dwi-bahasa dan checksum cocok dengan artifact.

## Di luar lingkup

Akun online, leaderboard cloud, layanan berbayar, aset berat dan engine selain LÖVE.
