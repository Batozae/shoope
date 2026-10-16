// Controller keranjang belanja
const pool = require('../config/db');

/**
 * Ambil isi keranjang user, dikelompokkan per toko
 */
const getCart = async (req, res, next) => {
  try {
    // Ambil semua item beserta info produk dan toko, urut shop_id lalu cart_items.id
    const [rows] = await pool.execute(
      `SELECT
         ci.id AS cart_item_id,
         ci.product_id, p.name, p.price, p.image_url, p.stock,
         ci.quantity,
         (p.price * ci.quantity) AS subtotal,
         s.id AS shop_id, s.name AS shop_name, s.is_mall
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       LEFT JOIN shops s ON p.shop_id = s.id
       WHERE ci.user_id = ?
       ORDER BY s.id ASC, ci.id ASC`,
      [req.user.id]
    );

    // Kelompokkan item per toko
    let totalPrice = 0;
    let totalItems = 0;
    const shopMap  = new Map(); // shop_id -> { shop_id, shop_name, is_mall, items }

    for (const row of rows) {
      const key = row.shop_id ?? 0; // produk tanpa toko masuk grup 0

      if (!shopMap.has(key)) {
        shopMap.set(key, {
          shop_id:   row.shop_id,
          shop_name: row.shop_name,
          is_mall:   Boolean(row.is_mall),
          items:     [],
        });
      }

      shopMap.get(key).items.push({
        product_id: row.product_id,
        name:       row.name,
        price:      row.price,
        image_url:  row.image_url,
        stock:      row.stock,
        quantity:   row.quantity,
        subtotal:   parseFloat(row.subtotal),
      });

      totalPrice += parseFloat(row.subtotal);
      totalItems += row.quantity;
    }

    return res.status(200).json({
      success: true,
      message: 'Keranjang berhasil diambil.',
      data: {
        shops:       Array.from(shopMap.values()),
        total_items: totalItems,
        total_price: totalPrice,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Tambah produk ke keranjang (atau tambah quantity jika sudah ada)
 */
const addToCart = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { product_id, quantity } = req.body;
    const qty = parseInt(quantity, 10) || 1;

    if (!product_id || qty < 1) {
      return res.status(400).json({
        success: false,
        message: 'Field product_id wajib dan quantity minimal 1.',
      });
    }

    // Cek apakah produk ada dan ambil stok
    const [products] = await pool.execute(
      'SELECT id, stock FROM products WHERE id = ?',
      [product_id]
    );

    if (products.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produk tidak ditemukan.',
      });
    }

    const stock = products[0].stock;

    // Cek quantity yang sudah ada di keranjang
    const [existing] = await pool.execute(
      'SELECT quantity FROM cart_items WHERE user_id = ? AND product_id = ?',
      [userId, product_id]
    );

    const currentQty = existing.length > 0 ? existing[0].quantity : 0;
    const newQty = currentQty + qty;

    // Validasi total quantity tidak melebihi stok
    if (newQty > stock) {
      return res.status(400).json({
        success: false,
        message: `Jumlah melebihi stok. Stok tersedia: ${stock}, di keranjang: ${currentQty}.`,
      });
    }

    // Insert atau update jika sudah ada
    await pool.execute(
      `INSERT INTO cart_items (user_id, product_id, quantity)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)`,
      [userId, product_id, qty]
    );

    return res.status(200).json({
      success: true,
      message: 'Produk berhasil ditambahkan ke keranjang.',
      data: { product_id, quantity: newQty },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update quantity item di keranjang
 */
const updateCartItem = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const productId = parseInt(req.params.productId, 10);
    const quantity = parseInt(req.body.quantity, 10);

    // Validasi quantity
    if (!quantity || quantity < 1) {
      return res.status(400).json({
        success: false,
        message: 'Quantity minimal 1.',
      });
    }

    // Cek stok produk
    const [products] = await pool.execute(
      'SELECT stock FROM products WHERE id = ?',
      [productId]
    );

    if (products.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produk tidak ditemukan.',
      });
    }

    if (quantity > products[0].stock) {
      return res.status(400).json({
        success: false,
        message: `Quantity melebihi stok. Stok tersedia: ${products[0].stock}.`,
      });
    }

    // Update quantity di keranjang
    const [result] = await pool.execute(
      'UPDATE cart_items SET quantity = ? WHERE user_id = ? AND product_id = ?',
      [quantity, userId, productId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Item tidak ditemukan di keranjang.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Quantity berhasil diperbarui.',
      data: { product_id: productId, quantity },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Hapus item dari keranjang
 */
const removeFromCart = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const productId = parseInt(req.params.productId, 10);

    const [result] = await pool.execute(
      'DELETE FROM cart_items WHERE user_id = ? AND product_id = ?',
      [userId, productId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Item tidak ditemukan di keranjang.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Item berhasil dihapus dari keranjang.',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getCart, addToCart, updateCartItem, removeFromCart };

