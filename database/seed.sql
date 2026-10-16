-- ============================================================
-- Shoope Seed Data
-- Data awal untuk kategori dan produk.
-- CATATAN: Tidak menyisipkan data users agar tidak ada
--          password plaintext di file SQL.
-- ============================================================

USE shoope_db;

-- ============================================================
-- Kategori produk (8 kategori)
-- ============================================================

INSERT INTO categories (id, name, icon_url) VALUES
  (1, 'Elektronik',              'https://picsum.photos/seed/cat1/100/100'),
  (2, 'Fashion Pria',            'https://picsum.photos/seed/cat2/100/100'),
  (3, 'Fashion Wanita',          'https://picsum.photos/seed/cat3/100/100'),
  (4, 'Makanan & Minuman',       'https://picsum.photos/seed/cat4/100/100'),
  (5, 'Kesehatan & Kecantikan',  'https://picsum.photos/seed/cat5/100/100'),
  (6, 'Perlengkapan Rumah',      'https://picsum.photos/seed/cat6/100/100'),
  (7, 'Olahraga',                'https://picsum.photos/seed/cat7/100/100'),
  (8, 'Aksesoris & Gadget',      'https://picsum.photos/seed/cat8/100/100');

-- ============================================================
-- Produk (30 produk tersebar di semua kategori)
-- Harga dalam Rupiah, rating 3.5-5.0, sold_count 10-5000
-- ============================================================

INSERT INTO products (id, category_id, name, description, price, stock, image_url, rating, sold_count) VALUES

-- Kategori 1: Elektronik (produk 1-4)
(1,  1, 'Earphone Bluetooth TWS',
     'Earphone wireless dengan noise cancelling, baterai tahan 6 jam. Cocok untuk musik dan telepon.',
     89000.00,  250, 'https://picsum.photos/seed/product1/400/400',  4.5, 3200),

(2,  1, 'Charger Fast Charging 20W',
     'Charger USB-C 20W kompatibel dengan berbagai smartphone. Pengisian cepat dan aman.',
     75000.00,  400, 'https://picsum.photos/seed/product2/400/400',  4.3, 4500),

(3,  1, 'Kabel Data Type-C 1 Meter',
     'Kabel data USB Type-C berkualitas tinggi, mendukung transfer data cepat dan pengisian daya.',
     25000.00,  800, 'https://picsum.photos/seed/product3/400/400',  4.1, 5000),

(4,  1, 'Powerbank 10000mAh Slim',
     'Powerbank kapasitas besar dengan desain tipis. Dilengkapi dual output USB-A dan USB-C.',
     150000.00, 180, 'https://picsum.photos/seed/product4/400/400',  4.6, 2800),

-- Kategori 2: Fashion Pria (produk 5-8)
(5,  2, 'Kaos Polos Pria Cotton Combed',
     'Kaos polos bahan cotton combed 30s, nyaman dipakai sehari-hari. Tersedia berbagai warna.',
     55000.00,  600, 'https://picsum.photos/seed/product5/400/400',  4.4, 4200),

(6,  2, 'Celana Jogger Pria',
     'Celana jogger slim fit bahan katun terry. Cocok untuk olahraga maupun santai.',
     120000.00, 300, 'https://picsum.photos/seed/product6/400/400',  4.2, 1800),

(7,  2, 'Sepatu Sneakers Casual Pria',
     'Sepatu sneakers desain modern, sol karet anti slip. Ringan dan nyaman untuk aktivitas harian.',
     275000.00, 150, 'https://picsum.photos/seed/product7/400/400',  4.7, 3100),

(8,  2, 'Topi Baseball Polos',
     'Topi baseball unisex bahan twill cotton, adjustable strap. Cocok untuk gaya kasual.',
     35000.00,  500, 'https://picsum.photos/seed/product8/400/400',  4.0, 2200),

-- Kategori 3: Fashion Wanita (produk 9-12)
(9,  3, 'Dress Casual Wanita',
     'Dress casual bahan rayon, motif bunga elegan. Cocok untuk acara santai maupun semi-formal.',
     135000.00, 200, 'https://picsum.photos/seed/product9/400/400',  4.5, 1500),

(10, 3, 'Tas Selempang Mini Wanita',
     'Tas selempang kecil bahan kulit sintetis, desain minimalis. Muat HP dan dompet.',
     85000.00,  350, 'https://picsum.photos/seed/product10/400/400', 4.3, 2700),

(11, 3, 'Hijab Pashmina Cerutti',
     'Hijab pashmina bahan cerutti babydoll, jatuh dan tidak mudah kusut.',
     45000.00,  700, 'https://picsum.photos/seed/product11/400/400', 4.6, 3800),

(12, 3, 'Sandal Flat Wanita',
     'Sandal flat simpel dengan tali silang, bahan kulit sintetis premium. Nyaman untuk jalan-jalan.',
     65000.00,  400, 'https://picsum.photos/seed/product12/400/400', 4.1, 1200),

-- Kategori 4: Makanan & Minuman (produk 13-16)
(13, 4, 'Mie Instan Box Isi 40',
     'Mie instan rasa favorit kemasan box isi 40 bungkus. Stok bulanan keluarga.',
     95000.00,  120, 'https://picsum.photos/seed/product13/400/400', 4.8, 4800),

(14, 4, 'Kopi Arabika Toraja 250g',
     'Biji kopi arabika pilihan dari Toraja, roasting medium. Aroma khas dan rasa nikmat.',
     78000.00,  200, 'https://picsum.photos/seed/product14/400/400', 4.7, 1600),

(15, 4, 'Keripik Singkong Pedas 500g',
     'Keripik singkong renyah level pedas, kemasan jumbo 500 gram. Camilan favorit.',
     32000.00,  450, 'https://picsum.photos/seed/product15/400/400', 4.4, 3500),

(16, 4, 'Teh Celup Jasmine Isi 50',
     'Teh celup melati premium isi 50 kantong. Nikmat diseduh hangat maupun dingin.',
     18000.00,  600, 'https://picsum.photos/seed/product16/400/400', 4.2, 2900),

-- Kategori 5: Kesehatan & Kecantikan (produk 17-20)
(17, 5, 'Masker Wajah Aloe Vera Isi 10',
     'Sheet mask aloe vera untuk melembapkan dan menenangkan kulit. Paket isi 10 lembar.',
     48000.00,  500, 'https://picsum.photos/seed/product17/400/400', 4.5, 4100),

(18, 5, 'Sunscreen SPF 50+ PA++++',
     'Sunscreen wajah ringan, tidak lengket, perlindungan maksimal dari sinar UV.',
     62000.00,  300, 'https://picsum.photos/seed/product18/400/400', 4.6, 3600),

(19, 5, 'Vitamin C 1000mg Isi 30 Tablet',
     'Suplemen vitamin C dosis tinggi untuk daya tahan tubuh. Isi 30 tablet kunyah rasa jeruk.',
     42000.00,  400, 'https://picsum.photos/seed/product19/400/400', 4.3, 2500),

(20, 5, 'Serum Wajah Niacinamide 10%',
     'Serum niacinamide untuk mencerahkan kulit dan mengecilkan pori-pori. Isi 30ml.',
     55000.00,  350, 'https://picsum.photos/seed/product20/400/400', 4.7, 3000),

-- Kategori 6: Perlengkapan Rumah (produk 21-24)
(21, 6, 'Rak Buku Minimalis 5 Tingkat',
     'Rak buku kayu particle board 5 tingkat, desain minimalis modern. Mudah dirakit.',
     245000.00, 80,  'https://picsum.photos/seed/product21/400/400', 4.4, 850),

(22, 6, 'Lampu LED Meja Belajar',
     'Lampu meja LED hemat energi dengan 3 level kecerahan. Cocok untuk belajar dan bekerja.',
     85000.00,  250, 'https://picsum.photos/seed/product22/400/400', 4.3, 1900),

(23, 6, 'Set Handuk Mandi Katun Isi 3',
     'Handuk mandi bahan katun lembut, daya serap tinggi. Paket isi 3 ukuran berbeda.',
     110000.00, 200, 'https://picsum.photos/seed/product23/400/400', 4.5, 1400),

(24, 6, 'Dispenser Air Galon Bawah',
     'Dispenser air dengan penempatan galon di bawah, fitur panas dan dingin. Desain elegan.',
     2500000.00, 30, 'https://picsum.photos/seed/product24/400/400', 4.6, 320),

-- Kategori 7: Olahraga (produk 25-27)
(25, 7, 'Matras Yoga Anti Slip 6mm',
     'Matras yoga bahan TPE anti slip, tebal 6mm. Ringan dan mudah dibawa.',
     125000.00, 200, 'https://picsum.photos/seed/product25/400/400', 4.5, 1700),

(26, 7, 'Dumbbell Set 10kg (2x5kg)',
     'Set dumbbell besi cor 2 x 5 kg, grip karet anti licin. Ideal untuk latihan di rumah.',
     185000.00, 100, 'https://picsum.photos/seed/product26/400/400', 4.4, 950),

(27, 7, 'Botol Minum Sport 750ml',
     'Botol minum olahraga anti tumpah, bahan tritan BPA-free. Kapasitas 750ml.',
     45000.00,  500, 'https://picsum.photos/seed/product27/400/400', 4.2, 2600),

-- Kategori 8: Aksesoris & Gadget (produk 28-30)
(28, 8, 'Smartwatch Sport Band',
     'Smartwatch dengan fitur heart rate, langkah kaki, dan notifikasi. Tahan air IP68.',
     350000.00, 120, 'https://picsum.photos/seed/product28/400/400', 4.5, 2100),

(29, 8, 'Ring Light 10 Inch + Tripod',
     'Ring light LED 10 inci dengan tripod adjustable, 3 mode cahaya. Cocok untuk foto dan video.',
     135000.00, 180, 'https://picsum.photos/seed/product29/400/400', 4.3, 1800),

(30, 8, 'Phone Holder Motor Anti Getar',
     'Holder HP untuk motor dengan sistem anti getar, universal 4.7-6.5 inch. Pemasangan mudah.',
     68000.00,  350, 'https://picsum.photos/seed/product30/400/400', 4.4, 3400);
