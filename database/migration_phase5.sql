USE shoope_db;

-- Toko
CREATE TABLE shops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  is_mall TINYINT(1) NOT NULL DEFAULT 0,
  logo_url VARCHAR(255) NULL
);

INSERT INTO shops (name, city, is_mall) VALUES
  ('Sinar Official Shop', 'KAB. TANGERANG', 1),
  ('Beauty Lab Official', 'JAKARTA BARAT', 1),
  ('Toko Makmur Jaya', 'SURABAYA', 0),
  ('Gadget Corner', 'BANDUNG', 0),
  ('Fashion Hub Store', 'JAKARTA SELATAN', 1);

-- Kolom baru produk
ALTER TABLE products
  ADD COLUMN shop_id INT NULL,
  ADD COLUMN original_price DECIMAL(12,2) NULL,
  ADD COLUMN rating_count INT NOT NULL DEFAULT 0;

UPDATE products SET
  shop_id = (id % 5) + 1,
  rating_count = 100 + (id * 137) % 5000,
  original_price = CASE WHEN id % 3 = 0 THEN NULL
    ELSE ROUND(price / (1 - (10 + (id % 5) * 10) / 100)) END
WHERE id > 0;

ALTER TABLE products
  MODIFY shop_id INT NOT NULL,
  ADD CONSTRAINT fk_products_shop FOREIGN KEY (shop_id) REFERENCES shops(id);

-- Galeri gambar (4 gambar per produk)
CREATE TABLE product_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT p.id, CONCAT('https://picsum.photos/seed/p', p.id, 'x', n.n, '/600/600'), n.n
FROM products p
CROSS JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) n;

-- Notifikasi
CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  category ENUM('promo','pesanan','info') NOT NULL,
  title VARCHAR(150) NOT NULL,
  body VARCHAR(500) NOT NULL,
  image_url VARCHAR(255) NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notif_user_cat (user_id, category)
);

-- Notifikasi awal untuk user yang sudah ada
INSERT INTO notifications (user_id, category, title, body)
SELECT id, 'promo', 'Selamat datang di Shoope!', 'Dapatkan diskon spesial untuk pembelian pertamamu.' FROM users;
INSERT INTO notifications (user_id, category, title, body)
SELECT id, 'info', 'Lengkapi profilmu', 'Tambahkan alamat pengiriman agar checkout lebih cepat.' FROM users;