// Controller produk
const pool = require('../config/db');

// Whitelist urutan yang diizinkan, petakan ke kolom SQL yang aman
const SORT_MAP = {
  newest:     'p.created_at DESC',
  price_asc:  'p.price ASC',
  price_desc: 'p.price DESC',
  popular:    'p.sold_count DESC',
};

/**
 * Ambil daftar produk dengan filter, pencarian, dan paginasi
 * GET /api/products
 * Query: search, category_id, sort, page, limit
 */
const getAllProducts = async (req, res, next) => {
  try {
    // --- Parsing & validasi query params ---
    const search      = req.query.search      || null;
    const categoryId  = req.query.category_id ? parseInt(req.query.category_id, 10) : null;
    const sortKey     = req.query.sort && SORT_MAP[req.query.sort] ? req.query.sort : 'newest';
    const orderClause = SORT_MAP[sortKey]; // aman: hanya dari whitelist

    const page  = Math.max(1, parseInt(req.query.page,  10) || 1);
    const limit = Math.min(50, Math.max(1, parseInt(req.query.limit, 10) || 10));
    const offset = (page - 1) * limit;

    // --- Bangun klausa WHERE secara dinamis ---
    const conditions = [];
    const params     = [];

    if (search) {
      conditions.push('p.name LIKE ?');
      params.push(`%${search}%`);
    }
    if (categoryId) {
      conditions.push('p.category_id = ?');
      params.push(categoryId);
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    // --- Hitung total data untuk paginasi ---
    const [countRows] = await pool.execute(
      `SELECT COUNT(*) AS total FROM products p ${whereClause}`,
      params
    );
    const total      = countRows[0].total;
    const totalPages = Math.ceil(total / limit);

    // --- Ambil data produk dengan JOIN ke categories ---
    const [products] = await pool.execute(
      `SELECT
         p.id, p.name, p.description, p.price, p.stock,
         p.image_url, p.rating, p.sold_count, p.created_at,
         p.category_id,
         c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       ${whereClause}
       ORDER BY ${orderClause}
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    return res.status(200).json({
      success: true,
      message: 'Daftar produk berhasil diambil.',
      data: {
        items: products,
        pagination: {
          page,
          limit,
          total,
          total_pages: totalPages,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Ambil detail satu produk berdasarkan id
 * GET /api/products/:id
 */
const getProductById = async (req, res, next) => {
  try {
    const productId = parseInt(req.params.id, 10);

    // Validasi id harus berupa angka valid
    if (isNaN(productId)) {
      return res.status(400).json({
        success: false,
        message: 'ID produk tidak valid.',
      });
    }

    const [rows] = await pool.execute(
      `SELECT
         p.id, p.name, p.description, p.price, p.stock,
         p.image_url, p.rating, p.sold_count, p.created_at,
         p.category_id,
         c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = ?`,
      [productId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produk tidak ditemukan.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Detail produk berhasil diambil.',
      data: rows[0],
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllProducts, getProductById };

