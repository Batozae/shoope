# MVP Shoope (Clone Shopee)

Aplikasi: Shopee -> Shoope
Stack: Flutter (Dart), Express.js, MySQL (XAMPP)

## Fitur MVP (in scope)

1. Auth: register, login (JWT), profil saya, logout
2. Home: banner statis, grid kategori, daftar produk (rekomendasi)
3. Pencarian produk + filter kategori
4. Detail produk: gambar, harga, stok, deskripsi, rating (statis dari seed)
5. Keranjang: tambah, ubah qty, hapus, total harga
6. Checkout: pilih alamat, metode pembayaran (simulasi), buat order
7. Riwayat pesanan + detail pesanan + ubah status (simulasi bayar)
8. Profil: lihat/ubah data & alamat

## Out of scope

Chat, live streaming, voucher kompleks, payment gateway asli, notifikasi push,
multi-seller dashboard, review upload foto.

## Database (MySQL: shoope_db)

users, addresses, categories, products, cart_items, orders, order_items

## Fase

1. Setup repo, database, Express + Auth
2. API Produk & Kategori
3. API Keranjang, Checkout, Pesanan
4. Flutter: fondasi (tema, routing, API client, state) + layar Auth
5. Flutter: Home, Pencarian, Detail Produk
6. Flutter: Keranjang, Checkout, Pesanan, Profil
7. Polish, README, rekam video

## Konvensi

- Response API: { success, message, data }
- Base URL emulator Android: http://10.0.2.2:3000/api
- Commit: conventional commits (feat, fix, chore, docs)
