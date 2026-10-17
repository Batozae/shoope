-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 17, 2026 at 04:19 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shoope_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `recipient_name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `full_address` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `postal_code` varchar(10) NOT NULL,
  `is_default` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon_url` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `icon_url`) VALUES
(1, 'Elektronik', 'https://picsum.photos/seed/cat1/100/100'),
(2, 'Fashion Pria', 'https://picsum.photos/seed/cat2/100/100'),
(3, 'Fashion Wanita', 'https://picsum.photos/seed/cat3/100/100'),
(4, 'Makanan & Minuman', 'https://picsum.photos/seed/cat4/100/100'),
(5, 'Kesehatan & Kecantikan', 'https://picsum.photos/seed/cat5/100/100'),
(6, 'Perlengkapan Rumah', 'https://picsum.photos/seed/cat6/100/100'),
(7, 'Olahraga', 'https://picsum.photos/seed/cat7/100/100'),
(8, 'Aksesoris & Gadget', 'https://picsum.photos/seed/cat8/100/100');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category` enum('promo','pesanan','info') NOT NULL,
  `title` varchar(150) NOT NULL,
  `body` varchar(500) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `address_id` int(11) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `status` enum('pending','paid','shipped','completed','cancelled') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_at_purchase` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(12,2) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `image_url` varchar(500) DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT 0.0,
  `sold_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `shop_id` int(11) NOT NULL,
  `original_price` decimal(12,2) DEFAULT NULL,
  `rating_count` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `description`, `price`, `stock`, `image_url`, `rating`, `sold_count`, `created_at`, `shop_id`, `original_price`, `rating_count`) VALUES
(1, 1, 'Earphone Bluetooth TWS', 'Earphone wireless dengan noise cancelling, baterai tahan 6 jam. Cocok untuk musik dan telepon.', 89000.00, 249, 'https://picsum.photos/seed/product1/400/400', 4.5, 3201, '2026-10-16 03:26:10', 2, 111250.00, 237),
(2, 1, 'Charger Fast Charging 20W', 'Charger USB-C 20W kompatibel dengan berbagai smartphone. Pengisian cepat dan aman.', 75000.00, 400, 'https://picsum.photos/seed/product2/400/400', 4.3, 4500, '2026-10-16 03:26:10', 3, 107143.00, 374),
(3, 1, 'Kabel Data Type-C 1 Meter', 'Kabel data USB Type-C berkualitas tinggi, mendukung transfer data cepat dan pengisian daya.', 25000.00, 800, 'https://picsum.photos/seed/product3/400/400', 4.1, 5000, '2026-10-16 03:26:10', 4, NULL, 511),
(4, 1, 'Powerbank 10000mAh Slim', 'Powerbank kapasitas besar dengan desain tipis. Dilengkapi dual output USB-A dan USB-C.', 150000.00, 180, 'https://picsum.photos/seed/product4/400/400', 4.6, 2800, '2026-10-16 03:26:10', 5, 300000.00, 648),
(5, 2, 'Kaos Polos Pria Cotton Combed', 'Kaos polos bahan cotton combed 30s, nyaman dipakai sehari-hari. Tersedia berbagai warna.', 55000.00, 600, 'https://picsum.photos/seed/product5/400/400', 4.4, 4200, '2026-10-16 03:26:10', 1, 61111.00, 785),
(6, 2, 'Celana Jogger Pria', 'Celana jogger slim fit bahan katun terry. Cocok untuk olahraga maupun santai.', 120000.00, 300, 'https://picsum.photos/seed/product6/400/400', 4.2, 1800, '2026-10-16 03:26:10', 2, NULL, 922),
(7, 2, 'Sepatu Sneakers Casual Pria', 'Sepatu sneakers desain modern, sol karet anti slip. Ringan dan nyaman untuk aktivitas harian.', 275000.00, 150, 'https://picsum.photos/seed/product7/400/400', 4.7, 3100, '2026-10-16 03:26:10', 3, 392857.00, 1059),
(8, 2, 'Topi Baseball Polos', 'Topi baseball unisex bahan twill cotton, adjustable strap. Cocok untuk gaya kasual.', 35000.00, 499, 'https://picsum.photos/seed/product8/400/400', 4.0, 2201, '2026-10-16 03:26:10', 4, 58333.00, 1196),
(9, 3, 'Dress Casual Wanita', 'Dress casual bahan rayon, motif bunga elegan. Cocok untuk acara santai maupun semi-formal.', 135000.00, 200, 'https://picsum.photos/seed/product9/400/400', 4.5, 1500, '2026-10-16 03:26:10', 5, NULL, 1333),
(10, 3, 'Tas Selempang Mini Wanita', 'Tas selempang kecil bahan kulit sintetis, desain minimalis. Muat HP dan dompet.', 85000.00, 350, 'https://picsum.photos/seed/product10/400/400', 4.3, 2700, '2026-10-16 03:26:10', 1, 94444.00, 1470),
(11, 3, 'Hijab Pashmina Cerutti', 'Hijab pashmina bahan cerutti babydoll, jatuh dan tidak mudah kusut.', 45000.00, 700, 'https://picsum.photos/seed/product11/400/400', 4.6, 3800, '2026-10-16 03:26:10', 2, 56250.00, 1607),
(12, 3, 'Sandal Flat Wanita', 'Sandal flat simpel dengan tali silang, bahan kulit sintetis premium. Nyaman untuk jalan-jalan.', 65000.00, 400, 'https://picsum.photos/seed/product12/400/400', 4.1, 1200, '2026-10-16 03:26:10', 3, NULL, 1744),
(13, 4, 'Mie Instan Box Isi 40', 'Mie instan rasa favorit kemasan box isi 40 bungkus. Stok bulanan keluarga.', 95000.00, 120, 'https://picsum.photos/seed/product13/400/400', 4.8, 4800, '2026-10-16 03:26:10', 4, 158333.00, 1881),
(14, 4, 'Kopi Arabika Toraja 250g', 'Biji kopi arabika pilihan dari Toraja, roasting medium. Aroma khas dan rasa nikmat.', 78000.00, 200, 'https://picsum.photos/seed/product14/400/400', 4.7, 1600, '2026-10-16 03:26:10', 5, 156000.00, 2018),
(15, 4, 'Keripik Singkong Pedas 500g', 'Keripik singkong renyah level pedas, kemasan jumbo 500 gram. Camilan favorit.', 32000.00, 450, 'https://picsum.photos/seed/product15/400/400', 4.4, 3500, '2026-10-16 03:26:10', 1, NULL, 2155),
(16, 4, 'Teh Celup Jasmine Isi 50', 'Teh celup melati premium isi 50 kantong. Nikmat diseduh hangat maupun dingin.', 18000.00, 600, 'https://picsum.photos/seed/product16/400/400', 4.2, 2900, '2026-10-16 03:26:10', 2, 22500.00, 2292),
(17, 5, 'Masker Wajah Aloe Vera Isi 10', 'Sheet mask aloe vera untuk melembapkan dan menenangkan kulit. Paket isi 10 lembar.', 48000.00, 500, 'https://picsum.photos/seed/product17/400/400', 4.5, 4100, '2026-10-16 03:26:10', 3, 68571.00, 2429),
(18, 5, 'Sunscreen SPF 50+ PA++++', 'Sunscreen wajah ringan, tidak lengket, perlindungan maksimal dari sinar UV.', 62000.00, 300, 'https://picsum.photos/seed/product18/400/400', 4.6, 3600, '2026-10-16 03:26:10', 4, NULL, 2566),
(19, 5, 'Vitamin C 1000mg Isi 30 Tablet', 'Suplemen vitamin C dosis tinggi untuk daya tahan tubuh. Isi 30 tablet kunyah rasa jeruk.', 42000.00, 400, 'https://picsum.photos/seed/product19/400/400', 4.3, 2500, '2026-10-16 03:26:10', 5, 84000.00, 2703),
(20, 5, 'Serum Wajah Niacinamide 10%', 'Serum niacinamide untuk mencerahkan kulit dan mengecilkan pori-pori. Isi 30ml.', 55000.00, 350, 'https://picsum.photos/seed/product20/400/400', 4.7, 3000, '2026-10-16 03:26:10', 1, 61111.00, 2840),
(21, 6, 'Rak Buku Minimalis 5 Tingkat', 'Rak buku kayu particle board 5 tingkat, desain minimalis modern. Mudah dirakit.', 245000.00, 80, 'https://picsum.photos/seed/product21/400/400', 4.4, 850, '2026-10-16 03:26:10', 2, NULL, 2977),
(22, 6, 'Lampu LED Meja Belajar', 'Lampu meja LED hemat energi dengan 3 level kecerahan. Cocok untuk belajar dan bekerja.', 85000.00, 250, 'https://picsum.photos/seed/product22/400/400', 4.3, 1900, '2026-10-16 03:26:10', 3, 121429.00, 3114),
(23, 6, 'Set Handuk Mandi Katun Isi 3', 'Handuk mandi bahan katun lembut, daya serap tinggi. Paket isi 3 ukuran berbeda.', 110000.00, 200, 'https://picsum.photos/seed/product23/400/400', 4.5, 1400, '2026-10-16 03:26:10', 4, 183333.00, 3251),
(24, 6, 'Dispenser Air Galon Bawah', 'Dispenser air dengan penempatan galon di bawah, fitur panas dan dingin. Desain elegan.', 2500000.00, 30, 'https://picsum.photos/seed/product24/400/400', 4.6, 320, '2026-10-16 03:26:10', 5, NULL, 3388),
(25, 7, 'Matras Yoga Anti Slip 6mm', 'Matras yoga bahan TPE anti slip, tebal 6mm. Ringan dan mudah dibawa.', 125000.00, 200, 'https://picsum.photos/seed/product25/400/400', 4.5, 1700, '2026-10-16 03:26:10', 1, 138889.00, 3525),
(26, 7, 'Dumbbell Set 10kg (2x5kg)', 'Set dumbbell besi cor 2 x 5 kg, grip karet anti licin. Ideal untuk latihan di rumah.', 185000.00, 100, 'https://picsum.photos/seed/product26/400/400', 4.4, 950, '2026-10-16 03:26:10', 2, 231250.00, 3662),
(27, 7, 'Botol Minum Sport 750ml', 'Botol minum olahraga anti tumpah, bahan tritan BPA-free. Kapasitas 750ml.', 45000.00, 500, 'https://picsum.photos/seed/product27/400/400', 4.2, 2600, '2026-10-16 03:26:10', 3, NULL, 3799),
(28, 8, 'Smartwatch Sport Band', 'Smartwatch dengan fitur heart rate, langkah kaki, dan notifikasi. Tahan air IP68.', 350000.00, 120, 'https://picsum.photos/seed/product28/400/400', 4.5, 2100, '2026-10-16 03:26:10', 4, 583333.00, 3936),
(29, 8, 'Ring Light 10 Inch + Tripod', 'Ring light LED 10 inci dengan tripod adjustable, 3 mode cahaya. Cocok untuk foto dan video.', 135000.00, 180, 'https://picsum.photos/seed/product29/400/400', 4.3, 1800, '2026-10-16 03:26:10', 5, 270000.00, 4073),
(30, 8, 'Phone Holder Motor Anti Getar', 'Holder HP untuk motor dengan sistem anti getar, universal 4.7-6.5 inch. Pemasangan mudah.', 68000.00, 350, 'https://picsum.photos/seed/product30/400/400', 4.4, 3400, '2026-10-16 03:26:10', 1, NULL, 4210);

-- --------------------------------------------------------

--
-- Table structure for table `product_images`
--

CREATE TABLE `product_images` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`, `sort_order`) VALUES
(1, 5, 'https://picsum.photos/seed/p5x1/600/600', 1),
(2, 10, 'https://picsum.photos/seed/p10x1/600/600', 1),
(3, 15, 'https://picsum.photos/seed/p15x1/600/600', 1),
(4, 20, 'https://picsum.photos/seed/p20x1/600/600', 1),
(5, 25, 'https://picsum.photos/seed/p25x1/600/600', 1),
(6, 30, 'https://picsum.photos/seed/p30x1/600/600', 1),
(7, 1, 'https://picsum.photos/seed/p1x1/600/600', 1),
(8, 6, 'https://picsum.photos/seed/p6x1/600/600', 1),
(9, 11, 'https://picsum.photos/seed/p11x1/600/600', 1),
(10, 16, 'https://picsum.photos/seed/p16x1/600/600', 1),
(11, 21, 'https://picsum.photos/seed/p21x1/600/600', 1),
(12, 26, 'https://picsum.photos/seed/p26x1/600/600', 1),
(13, 2, 'https://picsum.photos/seed/p2x1/600/600', 1),
(14, 5, 'https://picsum.photos/seed/p5x2/600/600', 2),
(15, 10, 'https://picsum.photos/seed/p10x2/600/600', 2),
(16, 15, 'https://picsum.photos/seed/p15x2/600/600', 2),
(17, 20, 'https://picsum.photos/seed/p20x2/600/600', 2),
(18, 25, 'https://picsum.photos/seed/p25x2/600/600', 2),
(19, 30, 'https://picsum.photos/seed/p30x2/600/600', 2),
(20, 1, 'https://picsum.photos/seed/p1x2/600/600', 2),
(21, 6, 'https://picsum.photos/seed/p6x2/600/600', 2),
(22, 11, 'https://picsum.photos/seed/p11x2/600/600', 2),
(23, 16, 'https://picsum.photos/seed/p16x2/600/600', 2),
(24, 21, 'https://picsum.photos/seed/p21x2/600/600', 2),
(25, 26, 'https://picsum.photos/seed/p26x2/600/600', 2),
(26, 2, 'https://picsum.photos/seed/p2x2/600/600', 2),
(27, 5, 'https://picsum.photos/seed/p5x3/600/600', 3),
(28, 10, 'https://picsum.photos/seed/p10x3/600/600', 3),
(29, 15, 'https://picsum.photos/seed/p15x3/600/600', 3),
(30, 20, 'https://picsum.photos/seed/p20x3/600/600', 3),
(31, 25, 'https://picsum.photos/seed/p25x3/600/600', 3),
(32, 30, 'https://picsum.photos/seed/p30x3/600/600', 3),
(33, 1, 'https://picsum.photos/seed/p1x3/600/600', 3),
(34, 6, 'https://picsum.photos/seed/p6x3/600/600', 3),
(35, 11, 'https://picsum.photos/seed/p11x3/600/600', 3),
(36, 16, 'https://picsum.photos/seed/p16x3/600/600', 3),
(37, 21, 'https://picsum.photos/seed/p21x3/600/600', 3),
(38, 26, 'https://picsum.photos/seed/p26x3/600/600', 3),
(39, 2, 'https://picsum.photos/seed/p2x3/600/600', 3),
(40, 5, 'https://picsum.photos/seed/p5x4/600/600', 4),
(41, 10, 'https://picsum.photos/seed/p10x4/600/600', 4),
(42, 15, 'https://picsum.photos/seed/p15x4/600/600', 4),
(43, 20, 'https://picsum.photos/seed/p20x4/600/600', 4),
(44, 25, 'https://picsum.photos/seed/p25x4/600/600', 4),
(45, 30, 'https://picsum.photos/seed/p30x4/600/600', 4),
(46, 1, 'https://picsum.photos/seed/p1x4/600/600', 4),
(47, 6, 'https://picsum.photos/seed/p6x4/600/600', 4),
(48, 11, 'https://picsum.photos/seed/p11x4/600/600', 4),
(49, 16, 'https://picsum.photos/seed/p16x4/600/600', 4),
(50, 21, 'https://picsum.photos/seed/p21x4/600/600', 4),
(51, 26, 'https://picsum.photos/seed/p26x4/600/600', 4),
(52, 2, 'https://picsum.photos/seed/p2x4/600/600', 4),
(53, 7, 'https://picsum.photos/seed/p7x1/600/600', 1),
(54, 12, 'https://picsum.photos/seed/p12x1/600/600', 1),
(55, 17, 'https://picsum.photos/seed/p17x1/600/600', 1),
(56, 22, 'https://picsum.photos/seed/p22x1/600/600', 1),
(57, 27, 'https://picsum.photos/seed/p27x1/600/600', 1),
(58, 3, 'https://picsum.photos/seed/p3x1/600/600', 1),
(59, 8, 'https://picsum.photos/seed/p8x1/600/600', 1),
(60, 13, 'https://picsum.photos/seed/p13x1/600/600', 1),
(61, 18, 'https://picsum.photos/seed/p18x1/600/600', 1),
(62, 23, 'https://picsum.photos/seed/p23x1/600/600', 1),
(63, 28, 'https://picsum.photos/seed/p28x1/600/600', 1),
(64, 4, 'https://picsum.photos/seed/p4x1/600/600', 1),
(65, 9, 'https://picsum.photos/seed/p9x1/600/600', 1),
(66, 7, 'https://picsum.photos/seed/p7x2/600/600', 2),
(67, 12, 'https://picsum.photos/seed/p12x2/600/600', 2),
(68, 17, 'https://picsum.photos/seed/p17x2/600/600', 2),
(69, 22, 'https://picsum.photos/seed/p22x2/600/600', 2),
(70, 27, 'https://picsum.photos/seed/p27x2/600/600', 2),
(71, 3, 'https://picsum.photos/seed/p3x2/600/600', 2),
(72, 8, 'https://picsum.photos/seed/p8x2/600/600', 2),
(73, 13, 'https://picsum.photos/seed/p13x2/600/600', 2),
(74, 18, 'https://picsum.photos/seed/p18x2/600/600', 2),
(75, 23, 'https://picsum.photos/seed/p23x2/600/600', 2),
(76, 28, 'https://picsum.photos/seed/p28x2/600/600', 2),
(77, 4, 'https://picsum.photos/seed/p4x2/600/600', 2),
(78, 9, 'https://picsum.photos/seed/p9x2/600/600', 2),
(79, 7, 'https://picsum.photos/seed/p7x3/600/600', 3),
(80, 12, 'https://picsum.photos/seed/p12x3/600/600', 3),
(81, 17, 'https://picsum.photos/seed/p17x3/600/600', 3),
(82, 22, 'https://picsum.photos/seed/p22x3/600/600', 3),
(83, 27, 'https://picsum.photos/seed/p27x3/600/600', 3),
(84, 3, 'https://picsum.photos/seed/p3x3/600/600', 3),
(85, 8, 'https://picsum.photos/seed/p8x3/600/600', 3),
(86, 13, 'https://picsum.photos/seed/p13x3/600/600', 3),
(87, 18, 'https://picsum.photos/seed/p18x3/600/600', 3),
(88, 23, 'https://picsum.photos/seed/p23x3/600/600', 3),
(89, 28, 'https://picsum.photos/seed/p28x3/600/600', 3),
(90, 4, 'https://picsum.photos/seed/p4x3/600/600', 3),
(91, 9, 'https://picsum.photos/seed/p9x3/600/600', 3),
(92, 7, 'https://picsum.photos/seed/p7x4/600/600', 4),
(93, 12, 'https://picsum.photos/seed/p12x4/600/600', 4),
(94, 17, 'https://picsum.photos/seed/p17x4/600/600', 4),
(95, 22, 'https://picsum.photos/seed/p22x4/600/600', 4),
(96, 27, 'https://picsum.photos/seed/p27x4/600/600', 4),
(97, 3, 'https://picsum.photos/seed/p3x4/600/600', 4),
(98, 8, 'https://picsum.photos/seed/p8x4/600/600', 4),
(99, 13, 'https://picsum.photos/seed/p13x4/600/600', 4),
(100, 18, 'https://picsum.photos/seed/p18x4/600/600', 4),
(101, 23, 'https://picsum.photos/seed/p23x4/600/600', 4),
(102, 28, 'https://picsum.photos/seed/p28x4/600/600', 4),
(103, 4, 'https://picsum.photos/seed/p4x4/600/600', 4),
(104, 9, 'https://picsum.photos/seed/p9x4/600/600', 4),
(105, 14, 'https://picsum.photos/seed/p14x1/600/600', 1),
(106, 19, 'https://picsum.photos/seed/p19x1/600/600', 1),
(107, 24, 'https://picsum.photos/seed/p24x1/600/600', 1),
(108, 29, 'https://picsum.photos/seed/p29x1/600/600', 1),
(109, 14, 'https://picsum.photos/seed/p14x2/600/600', 2),
(110, 19, 'https://picsum.photos/seed/p19x2/600/600', 2),
(111, 24, 'https://picsum.photos/seed/p24x2/600/600', 2),
(112, 29, 'https://picsum.photos/seed/p29x2/600/600', 2),
(113, 14, 'https://picsum.photos/seed/p14x3/600/600', 3),
(114, 19, 'https://picsum.photos/seed/p19x3/600/600', 3),
(115, 24, 'https://picsum.photos/seed/p24x3/600/600', 3),
(116, 29, 'https://picsum.photos/seed/p29x3/600/600', 3),
(117, 14, 'https://picsum.photos/seed/p14x4/600/600', 4),
(118, 19, 'https://picsum.photos/seed/p19x4/600/600', 4),
(119, 24, 'https://picsum.photos/seed/p24x4/600/600', 4),
(120, 29, 'https://picsum.photos/seed/p29x4/600/600', 4);

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE `shops` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `is_mall` tinyint(1) NOT NULL DEFAULT 0,
  `logo_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`id`, `name`, `city`, `is_mall`, `logo_url`) VALUES
(1, 'Sinar Official Shop', 'KAB. TANGERANG', 1, NULL),
(2, 'Beauty Lab Official', 'JAKARTA BARAT', 1, NULL),
(3, 'Toko Makmur Jaya', 'SURABAYA', 0, NULL),
(4, 'Gadget Corner', 'BANDUNG', 0, NULL),
(5, 'Fashion Hub Store', 'JAKARTA SELATAN', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_addresses_user_id` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_cart_user_product` (`user_id`,`product_id`),
  ADD KEY `fk_cart_product` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notif_user_cat` (`user_id`,`category`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_orders_user_id` (`user_id`),
  ADD KEY `fk_orders_address` (`address_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order_items_order` (`order_id`),
  ADD KEY `fk_order_items_product` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_products_category_id` (`category_id`),
  ADD KEY `fk_products_shop` (`shop_id`);

--
-- Indexes for table `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `fk_addresses_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_address` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`);

--
-- Constraints for table `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
