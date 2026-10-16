-- ============================================================
-- Shoope Database Schema
-- Database e-commerce Shoope - MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS shoope_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE shoope_db;

-- ============================================================
-- Hapus tabel dalam urutan terbalik dependensi agar tidak
-- terjadi error foreign key saat re-run script ini.
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS users;

-- ============================================================
-- Tabel pengguna (users)
-- Menyimpan data akun pengguna yang terdaftar.
-- ============================================================

CREATE TABLE users (
  id            INT           AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100)  NOT NULL,
  email         VARCHAR(255)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  phone         VARCHAR(20),
  avatar_url    VARCHAR(500),
  created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel alamat pengiriman (addresses)
-- Setiap pengguna bisa punya banyak alamat; satu bisa default.
-- ============================================================

CREATE TABLE addresses (
  id             INT           AUTO_INCREMENT PRIMARY KEY,
  user_id        INT           NOT NULL,
  recipient_name VARCHAR(100)  NOT NULL,
  phone          VARCHAR(20)   NOT NULL,
  full_address   TEXT          NOT NULL,
  city           VARCHAR(100)  NOT NULL,
  postal_code    VARCHAR(10)   NOT NULL,
  is_default     BOOLEAN       DEFAULT FALSE,

  INDEX idx_addresses_user_id (user_id),

  CONSTRAINT fk_addresses_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel kategori produk (categories)
-- Kategori utama untuk mengelompokkan produk.
-- ============================================================

CREATE TABLE categories (
  id       INT           AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(100)  NOT NULL,
  icon_url VARCHAR(500)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel produk (products)
-- Menyimpan detail setiap produk yang dijual.
-- ============================================================

CREATE TABLE products (
  id          INT            AUTO_INCREMENT PRIMARY KEY,
  category_id INT,
  name        VARCHAR(255)   NOT NULL,
  description TEXT,
  price       DECIMAL(12,2)  NOT NULL,
  stock       INT            DEFAULT 0,
  image_url   VARCHAR(500),
  rating      DECIMAL(2,1)   DEFAULT 0.0,
  sold_count  INT            DEFAULT 0,
  created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_products_category_id (category_id),

  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel keranjang belanja (cart_items)
-- Satu user hanya bisa punya satu entry per produk di keranjang.
-- ============================================================

CREATE TABLE cart_items (
  id         INT  AUTO_INCREMENT PRIMARY KEY,
  user_id    INT  NOT NULL,
  product_id INT  NOT NULL,
  quantity   INT  NOT NULL DEFAULT 1,

  UNIQUE KEY uk_cart_user_product (user_id, product_id),

  CONSTRAINT fk_cart_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_cart_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel pesanan (orders)
-- Menyimpan informasi pesanan yang dibuat oleh pengguna.
-- ============================================================

CREATE TABLE orders (
  id             INT                                                        AUTO_INCREMENT PRIMARY KEY,
  user_id        INT                                                        NOT NULL,
  address_id     INT                                                        NOT NULL,
  total_price    DECIMAL(12,2)                                              NOT NULL,
  payment_method VARCHAR(50),
  status         ENUM('pending','paid','shipped','completed','cancelled')   DEFAULT 'pending',
  created_at     TIMESTAMP                                                  DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_orders_user_id (user_id),

  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_orders_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Tabel item pesanan (order_items)
-- Detail produk yang termasuk dalam setiap pesanan.
-- Harga disimpan saat pembelian agar tidak berubah jika harga produk berubah.
-- ============================================================

CREATE TABLE order_items (
  id                INT            AUTO_INCREMENT PRIMARY KEY,
  order_id          INT            NOT NULL,
  product_id        INT            NOT NULL,
  quantity          INT            NOT NULL,
  price_at_purchase DECIMAL(12,2)  NOT NULL,

  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
