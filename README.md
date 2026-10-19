# Shoope (Clone Shopee)

Aplikasi **Shoope** adalah aplikasi mobile e-commerce clone dari **Shopee** yang dibangun dengan antarmuka Flutter dan backend Node.js (Express) serta database MySQL. Proyek ini berfokus pada implementasi fitur-fitur inti e-commerce dengan meniru tampilan antarmuka Shopee semirip mungkin.

### Tech Stack

- **Mobile Frontend**: Flutter (Dart) — State Management via `provider`, HTTP client via `http`, penyimpanan lokal via `shared_preferences`, formatting via `intl`.
- **Backend REST API**: Node.js, Express.js, MySQL (`mysql2`), JWT (`jsonwebtoken`), Password Hashing (`bcryptjs`), CORS (`cors`), Environment (`dotenv`), Nodemon.
- **Database**: MySQL (dijalankan via XAMPP).

---

## Anggota Kelompok

| NAMA                             |     NIM     |

| FATIH RAHMAN AL-BANTANI          | 24051214148 |

| NARENDRA RIO NOVENDI             | 24051214160 |

| DANIEL REVANKA ARDIANTO PUTRA    | 24051214170 |

| MOH VIKI NUR ARIFIN              | 24051214171 |

---

## Fitur Utama

### 1. Fitur Fungsional (Terintegrasi Backend)

- **Autentikasi & Akun**: Registrasi user baru, login berbasis token JWT, profil pengguna, dan ubah profil (nama & nomor telepon).
- **Beranda & Katalog Produk**: Daftar produk (tampilan grid 2 kolom), badge diskon, badge Mall, lokasi kota toko, serta pull-to-refresh.
- **Pencarian & Filter**: Pencarian produk berdasarkan nama, filter per kategori, pengurutan (_terbaru_, _termurah_, _termahal_, _terlaris_), serta penomoran halaman (pagination).
- **Detail Produk**: Galeri gambar interaktif, harga & harga coret diskon, stok, rating produk, jumlah terjual, dan informasi toko penjual.
- **Keranjang Belanja**: Produk dikelompokkan berdasarkan toko, pemilihan item via checkbox, pengubahan kuantitas produk, dan penghapusan item.
- **Checkout & Pesanan**: Pemilihan alamat pengiriman utama/alternatif, pilihan metode pembayaran simulasi (COD, Transfer Bank, E-Wallet), pembuatan pesanan langsung dari item terpilih di keranjang.
- **Manajemen Pesanan**: Riwayat pesanan berdasarkan status (_Semua, Belum Bayar, Dikemas, Dikirim, Selesai, Dibatalkan_), detail pesanan, simulasi pembayaran, pembatalan pesanan, serta simulasi pengiriman dan penyelesaian pesanan.
- **Alamat Pengiriman**: Daftar alamat tersimpan, penambahan alamat baru lengkap dengan validasi, set alamat utama, dan penghapusan alamat.
- **Notifikasi**: Notifikasi akun per kategori (_Promo, Status Pesanan, Info_), penanda pesan telah dibaca, dan badge belum dibaca.
- **Menu Saya (Profil)**: Ringkasan jumlah pesanan aktif per status transaksi, tautan cepat ke alamat saya, serta fitur logout.

### 2. Tampilan Statis (Elemen UI Simulasi)

- Banner promosi beranda, menu jalan pintas (Pulsa & Tagihan, ShopeeFood, ShopeeVIP, dll.), bar saldo ShopeePay & Koin, tab navigasi Live & Video, bar status VIP/dompet, tombol favorit lokal, baris voucher toko, serta tombol chat.
- Seluruh elemen statis interaktif memunculkan notifikasi SnackBar _"Segera hadir"_.

---

## Struktur Folder

```
shoope/
├── api/                   # Backend REST API (Node.js & Express)
│   ├── src/
│   │   ├── config/        # Koneksi database MySQL pool
│   │   ├── controllers/   # Logika bisnis endpoint (auth, product, cart, order, dll.)
│   │   ├── middleware/    # Auth JWT & penanganan error terpusat
│   │   ├── routes/        # Rute API RESTful
│   │   └── utils/         # Helper notifikasi otomatis
│   ├── .env.example       # Template environment variable backend
│   ├── package.json       # Dependencies backend
│   └── server.js          # Entry point server API
├── database/              # File skrip dan migrasi basis data MySQL
│   ├── schema.sql         # Skema tabel dasar
│   ├── seed.sql           # Data awal kategori & 30 produk
│   ├── migration_phase5.sql # Migrasi toko, galeri gambar, & notifikasi
│   └── shoope_full.sql    # Dump database lengkap terpadu (alternatif satu kali jalan)
├── docs/                  # Dokumentasi proyek (MVP.md)
├── lib/                   # Frontend aplikasi Flutter
│   ├── config/            # Konfigurasi dasar endpoint API (api_config.dart)
│   ├── models/            # Model data Dart (User, Product, Cart, Order, Address, dll.)
│   ├── providers/         # State management ChangeNotifier (Auth, Cart, Notification)
│   ├── screens/           # Tampilan antarmuka per modul (auth, home, product, cart, checkout, order, profile, dll.)
│   ├── services/          # HTTP request service ke Backend API
│   ├── theme/             # Definisi tema visual, warna Shopee, & dimensi konsisten (AppDimens)
│   ├── utils/             # Format mata uang Rupiah & format angka
│   ├── widgets/           # Reusable component (ProductCard, MainShell, dll.)
│   └── main.dart          # Entry point aplikasi Flutter
├── pubspec.yaml           # Dependencies Flutter
└── README.md              # Dokumentasi utama proyek
```

---

## Panduan Menjalankan

Ikuti langkah-langkah berikut secara berurutan untuk menjalankan proyek dari awal:

### 1. Prasyarat Sistem

Pastikan telah menginstal:

- **Flutter SDK** (versi 3.13.2 atau lebih baru)
- **Node.js** (versi 18 ke atas) dan **npm**
- **XAMPP** (untuk MySQL Database & phpMyAdmin)
- **Emulator Android** (Android Studio), browser Chrome, atau smartphone Android fisik dengan mode USB Debugging aktif.

---

### 2. Konfigurasi Database (MySQL)

1. Buka aplikasi **XAMPP Control Panel**, lalu klik **Start** pada modul **MySQL** (dan Apache untuk akses phpMyAdmin).
2. Buka browser dan masuk ke **phpMyAdmin** di `http://localhost/phpmyadmin`.
3. Buat database baru bernama `shoope_db` (atau biarkan dibuat otomatis oleh skrip).
4. Impor file SQL yang ada pada folder `database/`. Anda dapat memilih salah satu dari **dua opsi** berikut:
   - **Opsi A (Rekomendasi - Satu Kali Eksekusi)**:
     Impor langsung file dump lengkap:

     ```
     database/shoope_full.sql
     ```

   - **Opsi B (Bertahap Sesuai Urutan Migrasi)**:
     Impor file secara berurutan:
     1. `database/schema.sql` (membuat tabel dasar)
     2. `database/seed.sql` (mengisi data kategori dan produk awal)
     3. `database/migration_phase5.sql` (menambahkan tabel toko, galeri gambar, notifikasi, dan relasi toko pada produk)

   > **Penting**: Script `database/migration_phase5.sql` menggunakan perintah `ALTER TABLE` dan `UPDATE` data. Jalankan skrip migrasi ini **hanya satu kali** setelah `schema.sql` dan `seed.sql`. Jangan menjalankan `migration_phase5.sql` jika Anda sudah memilih Opsi A (`shoope_full.sql`), agar tidak terjadi duplikasi data atau error _duplicate column_.

---

### 3. Menjalankan Backend API

1. Buka terminal, masuk ke folder backend:
   ```bash
   cd api
   ```
2. Buat file `.env` dengan menyalin template yang ada:
   ```bash
   # Di Windows Command Prompt / PowerShell:
   copy .env.example .env
   ```
3. Buka file `api/.env`, pastikan kredensial database sudah sesuai dengan konfigurasi MySQL lokal Anda (default XAMPP biasanya `DB_USER=root` dan `DB_PASSWORD=` kosong):
   ```env
   PORT=3000
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=shoope_db
   JWT_SECRET=shoope_jwt_secret_key_2024
   JWT_EXPIRES_IN=7d
   ```
4. Install dependensi modul:
   ```bash
   npm install
   ```
5. Jalankan server dalam mode development:
   ```bash
   npm run dev
   ```
   _(Server akan berjalan di `http://localhost:3000`)_
6. Cek status API melalui browser di `http://localhost:3000/api/health`. Jika berhasil, akan muncul response:
   ```json
   {
     "success": true,
     "message": "Server berjalan & database terhubung.",
     "data": { ... }
   }
   ```

---

### 4. Menjalankan Aplikasi Flutter

1. Buka terminal baru di root folder proyek (`shoope/`).
2. Pasang dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Sesuaikan alamat IP backend pada file `lib/config/api_config.dart` sesuai dengan target perangkat yang digunakan:
   - **Emulator Android standar**:
     Gunakan alamat bawaan alias host emulator:
     ```dart
     const String baseUrl = 'http://10.0.2.2:3000/api';
     ```
   - **Google Chrome (Web)**:
     Sudah otomatis terdeteksi via `kIsWeb`, menggunakan `http://localhost:3000/api`.
   - **Smartphone Fisik (HP Android via Wi-Fi/Kabel)**:
     - _Metode 1 (Wi-Fi satu jaringan)_: Ganti IP laptop Anda, misalnya `http://192.168.1.XX:3000/api`. Pastikan firewall laptop mengizinkan port 3000.
     - _Metode 2 (Reverse port via kabel USB)_: Jalankan perintah ADB di terminal:
       ```bash
       adb reverse tcp:3000 tcp:3000
       ```
       Lalu atur `baseUrl` menjadi `http://localhost:3000/api`.
4. Jalankan aplikasi Flutter:
   ```bash
   flutter run
   ```

---

## Catatan & Informasi Tambahan

### Akun Uji Coba

Data seed database sengaja tidak menyisipkan akun pengguna awal demi keamanan hashing password.

- Untuk menguji aplikasi, silakan **buat akun baru** terlebih dahulu melalui tombol **Daftar** di halaman awal aplikasi (masukkan Nama, Email valid, dan Password minimal 6 karakter).
- Anda juga dapat mendaftarkan beberapa akun untuk menguji fitur multi-pengguna.

### Masalah Umum dan Solusi

1. **Gagal Registrasi / Login ("Connection refused" atau "Failed to connect to /10.0.2.2:3000")**:
   - Pastikan backend API sudah berjalan (`npm run dev` di folder `api/`).
   - Jika menggunakan smartphone fisik, pastikan perangkat dan laptop terhubung ke jaringan Wi-Fi yang sama dan gunakan IP LAN laptop pada `api_config.dart`, atau gunakan `adb reverse tcp:3000 tcp:3000`.
2. **Database Error saat Menjalankan API ("ECONNREFUSED" / "ER_BAD_DB_ERROR")**:
   - Pastikan modul MySQL di XAMPP sudah dalam status **Running**.
   - Pastikan nama database di file `api/.env` adalah `shoope_db` dan file database sudah berhasil diimpor.
3. **Data Produk atau Kategori Kosong di Beranda**:
   - Pastikan tabel produk sudah terisi dengan menjalankan `database/seed.sql` atau menggunakan `database/shoope_full.sql`.
   - Periksa apakah kolom `shop_id` pada tabel `products` sudah terbentuk dan terisi dengan benar.
4. **Error Duplicate Column pada MySQL saat Impor**:
   - Terjadi karena menjalankan `database/migration_phase5.sql` lebih dari satu kali atau menjalankannya setelah `shoope_full.sql`.
   - Solusi: Hapus database `shoope_db`, buat ulang database kosong `shoope_db`, dan impor file `database/shoope_full.sql` saja.
