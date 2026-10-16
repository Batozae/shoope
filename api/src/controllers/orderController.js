// Controller pesanan (orders)
const pool = require('../config/db');

// Whitelist metode pembayaran yang diizinkan
const ALLOWED_PAYMENT_METHODS = ['COD', 'Transfer Bank', 'E-Wallet'];

/**
 * Buat pesanan baru dari isi keranjang (dalam transaksi)
 */
const createOrder = async (req, res, next) => {
  const conn = await pool.getConnection();
  try {
    const userId = req.user.id;
    const { address_id, payment_method } = req.body;

    // Validasi input
    if (!address_id || !payment_method) {
      return res.status(400).json({
        success: false,
        message: 'Field address_id dan payment_method wajib diisi.',
      });
    }

    // Validasi payment_method dari whitelist
    if (!ALLOWED_PAYMENT_METHODS.includes(payment_method)) {
      return res.status(400).json({
        success: false,
        message: `Metode pembayaran tidak valid. Pilihan: ${ALLOWED_PAYMENT_METHODS.join(', ')}.`,
      });
    }

    // Pastikan alamat milik user
    const [addrRows] = await conn.execute(
      'SELECT id FROM addresses WHERE id = ? AND user_id = ?',
      [address_id, userId]
    );

    if (addrRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Alamat tidak ditemukan.',
      });
    }

    await conn.beginTransaction();

    // 1) Ambil cart_items + data produk dengan FOR UPDATE (kunci baris stok)
    const [cartItems] = await conn.execute(
      `SELECT ci.product_id, ci.quantity, p.name, p.price, p.stock
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       WHERE ci.user_id = ?
       FOR UPDATE`,
      [userId]
    );

    // Jika keranjang kosong
    if (cartItems.length === 0) {
      await conn.rollback();
      return res.status(400).json({
        success: false,
        message: 'Keranjang belanja kosong.',
      });
    }

    // 2) Validasi stok cukup untuk setiap item
    for (const item of cartItems) {
      if (item.quantity > item.stock) {
        await conn.rollback();
        return res.status(400).json({
          success: false,
          message: `Stok "${item.name}" tidak cukup. Tersedia: ${item.stock}, diminta: ${item.quantity}.`,
        });
      }
    }

    // 3) Hitung total_price di server dari harga tabel products
    let totalPrice = 0;
    for (const item of cartItems) {
      totalPrice += parseFloat(item.price) * item.quantity;
    }

    // 4a) Insert pesanan
    const [orderResult] = await conn.execute(
      'INSERT INTO orders (user_id, address_id, total_price, payment_method, status) VALUES (?, ?, ?, ?, ?)',
      [userId, address_id, totalPrice, payment_method, 'pending']
    );
    const orderId = orderResult.insertId;

    // 4b) Insert order_items dan kurangi stok produk
    for (const item of cartItems) {
      await conn.execute(
        'INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES (?, ?, ?, ?)',
        [orderId, item.product_id, item.quantity, item.price]
      );

      await conn.execute(
        'UPDATE products SET stock = stock - ?, sold_count = sold_count + ? WHERE id = ?',
        [item.quantity, item.quantity, item.product_id]
      );
    }

    // 4c) Kosongkan keranjang user
    await conn.execute('DELETE FROM cart_items WHERE user_id = ?', [userId]);

    await conn.commit();

    return res.status(201).json({
      success: true,
      message: 'Pesanan berhasil dibuat.',
      data: {
        id: orderId,
        total_price: totalPrice,
        payment_method,
        status: 'pending',
      },
    });
  } catch (error) {
    await conn.rollback();
    next(error);
  } finally {
    conn.release();
  }
};

/**
 * Ambil daftar pesanan milik user (opsional filter status)
 */
const getOrders = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    let query = `
      SELECT
        o.id, o.total_price, o.payment_method, o.status, o.created_at,
        COUNT(oi.id) AS item_count,
        MIN(p.name) AS first_product_name,
        MIN(p.image_url) AS first_product_image
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      JOIN products p ON oi.product_id = p.id
      WHERE o.user_id = ?
    `;
    const params = [userId];

    // Filter opsional berdasarkan status
    if (status) {
      query += ' AND o.status = ?';
      params.push(status);
    }

    query += ' GROUP BY o.id ORDER BY o.created_at DESC';

    const [orders] = await pool.execute(query, params);

    return res.status(200).json({
      success: true,
      message: 'Daftar pesanan berhasil diambil.',
      data: orders,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Ambil detail pesanan: info order, alamat, dan daftar item
 */
const getOrderById = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const orderId = parseInt(req.params.id, 10);

    // Ambil data order + alamat
    const [orderRows] = await pool.execute(
      `SELECT
         o.id, o.total_price, o.payment_method, o.status, o.created_at,
         a.recipient_name, a.phone, a.full_address, a.city, a.postal_code
       FROM orders o
       JOIN addresses a ON o.address_id = a.id
       WHERE o.id = ? AND o.user_id = ?`,
      [orderId, userId]
    );

    if (orderRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pesanan tidak ditemukan.',
      });
    }

    // Ambil daftar item pesanan
    const [items] = await pool.execute(
      `SELECT
         oi.product_id, p.name, p.image_url,
         oi.quantity, oi.price_at_purchase,
         (oi.quantity * oi.price_at_purchase) AS subtotal
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [orderId]
    );

    const order = orderRows[0];

    return res.status(200).json({
      success: true,
      message: 'Detail pesanan berhasil diambil.',
      data: {
        id: order.id,
        total_price: order.total_price,
        payment_method: order.payment_method,
        status: order.status,
        created_at: order.created_at,
        address: {
          recipient_name: order.recipient_name,
          phone: order.phone,
          full_address: order.full_address,
          city: order.city,
          postal_code: order.postal_code,
        },
        items,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Simulasi pembayaran: ubah status 'pending' -> 'paid'
 */
const payOrder = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const orderId = parseInt(req.params.id, 10);

    // Ambil pesanan milik user
    const [rows] = await pool.execute(
      'SELECT id, status FROM orders WHERE id = ? AND user_id = ?',
      [orderId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pesanan tidak ditemukan.',
      });
    }

    if (rows[0].status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Pesanan tidak bisa dibayar. Status saat ini: ${rows[0].status}.`,
      });
    }

    await pool.execute(
      'UPDATE orders SET status = ? WHERE id = ?',
      ['paid', orderId]
    );

    return res.status(200).json({
      success: true,
      message: 'Pembayaran berhasil. Status pesanan: paid.',
      data: { id: orderId, status: 'paid' },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Batalkan pesanan: ubah status 'pending' -> 'cancelled', kembalikan stok
 */
const cancelOrder = async (req, res, next) => {
  const conn = await pool.getConnection();
  try {
    const userId = req.user.id;
    const orderId = parseInt(req.params.id, 10);

    // Ambil pesanan milik user
    const [rows] = await conn.execute(
      'SELECT id, status FROM orders WHERE id = ? AND user_id = ?',
      [orderId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pesanan tidak ditemukan.',
      });
    }

    if (rows[0].status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Pesanan tidak bisa dibatalkan. Status saat ini: ${rows[0].status}.`,
      });
    }

    await conn.beginTransaction();

    // Ambil item pesanan untuk mengembalikan stok
    const [items] = await conn.execute(
      'SELECT product_id, quantity FROM order_items WHERE order_id = ?',
      [orderId]
    );

    // Kembalikan stok dan kurangi sold_count
    for (const item of items) {
      await conn.execute(
        'UPDATE products SET stock = stock + ?, sold_count = sold_count - ? WHERE id = ?',
        [item.quantity, item.quantity, item.product_id]
      );
    }

    // Ubah status pesanan
    await conn.execute(
      'UPDATE orders SET status = ? WHERE id = ?',
      ['cancelled', orderId]
    );

    await conn.commit();

    return res.status(200).json({
      success: true,
      message: 'Pesanan berhasil dibatalkan. Stok dikembalikan.',
      data: { id: orderId, status: 'cancelled' },
    });
  } catch (error) {
    await conn.rollback();
    next(error);
  } finally {
    conn.release();
  }
};

module.exports = { createOrder, getOrders, getOrderById, payOrder, cancelOrder };

