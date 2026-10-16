# MVP Shoope (Clone Shopee) - Revisi 1

Aplikasi: Shopee -> Shoope
Stack: Flutter (Dart), Express.js, MySQL (XAMPP)
Prinsip: tiru tampilan semirip mungkin; fitur backend hanya yang inti.

## Fitur dengan backend (REAL)

1. Auth: register, login (JWT), profil, ubah profil
2. Beranda: daftar produk (grid 2 kolom) dengan badge diskon, badge Mall, lokasi toko
3. Pencarian + filter kategori + sort + pagination
4. Detail produk: galeri gambar, harga + harga coret, terjual, rating + jumlah rating, info toko
5. Keranjang: dikelompokkan per toko, ubah qty, hapus, pilih item (checkbox, di sisi client)
6. Checkout item terpilih: pilih alamat, metode pembayaran (simulasi), buat pesanan
7. Pesanan: riwayat per status, detail, bayar (simulasi), batalkan, lanjutkan status (simulasi kirim/selesai)
8. Notifikasi: daftar per kategori, tandai dibaca, badge jumlah belum dibaca
9. Saya: ringkasan jumlah pesanan per status (Belum Bayar, Dikemas, Dikirim, Beri Penilaian), alamat saya, keluar

## Tampilan statis (tanpa backend)

Banner beranda, menu ikon (Pulsa & Tagihan, ShopeeFood, ShopeeVIP, dst.), strip saldo/koin,
Shopee Live, tab Live & Video, bar VIP dan dompet di Saya, menu Pengaturan selain Alamat Saya
dan Keluar, ikon hati wishlist (lokal saja), baris voucher, tombol chat.
Tap pada elemen statis menampilkan snackbar "Segera hadir".

## Out of scope

Chat, live streaming, voucher/koin sungguhan, payment gateway, push notification,
varian produk, ulasan foto, wishlist tersimpan, passkey, dashboard penjual, pencarian kamera.

## Database (MySQL: shoope_db)

users, addresses, categories, shops, products, product_images,
cart_items, orders, order_items, notifications

## Fase

1-3 (selesai): Setup + Auth, API Produk, API Alamat/Keranjang/Pesanan
5: Backend revisi (migrasi DB, produk+toko+galeri, keranjang per toko, checkout item terpilih, notifikasi, ringkasan pesanan, ubah profil)
4: Flutter fondasi (tema, routing, API client, state) + layar Auth
6: Flutter Beranda, Pencarian, Detail Produk
7: Flutter Keranjang, Checkout, Pesanan
8: Flutter Notifikasi, Saya, Pengaturan
9: Polish, README, rekam video, submit

## Konvensi

- Response API: { success, message, data }
- Base URL emulator Android: http://10.0.2.2:3000/api
- Commit: conventional commits (feat, fix, chore, docs)
