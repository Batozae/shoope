// Controller produk
const pool = require('../config/db');

// Whitelist urutan yang diizinkan, petakan ke kolom SQL yang aman
const SORT_MAP = {
  newest:     'p.created_at DESC',
  price_asc:  'p.price ASC',
  price_desc: 'p.price DESC',
  popular:    'p.sold_count DESC',
};

// Kolom SELECT produk yang disertakan di list maupun detail (termasuk JOIN shops)
const PRODUCT_SELECT = `
  p.id, p.name, p.description, p.price, p.stock,
  p.image_url, p.rating, p.rating_count, p.sold_count, p.created_at,
  p.category_id,
  c.name AS category_name,
  p.shop_id,
  s.name AS shop_name,
  s.city AS shop_city,
  s.is_mall,
  p.original_price,
  CASE
    WHEN p.original_price > p.price
    THEN ROUND((1 - p.price / p.original_price) * 100)
    ELSE 0
  END AS discount_percent
`;

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

    const page   = Math.max(1, parseInt(req.query.page,  10) || 1);
    const limit  = Math.min(50, Math.max(1, parseInt(req.query.limit, 10) || 10));
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

    // --- Ambil data produk dengan JOIN ke categories dan shops ---
    const [products] = await pool.execute(
      `SELECT ${PRODUCT_SELECT}
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN shops s ON p.shop_id = s.id
       ${whereClause}
       ORDER BY ${orderClause}
       LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    // Konversi is_mall ke boolean JavaScript
    const items = products.map((p) => ({ ...p, is_mall: Boolean(p.is_mall) }));

    return res.status(200).json({
      success: true,
      message: 'Daftar produk berhasil diambil.',
      data: {
        items,
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
 * Ambil detail satu produk berdasarkan id (+ array images)
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

    // Ambil data produk + info toko + diskon
    const [rows] = await pool.execute(
      `SELECT ${PRODUCT_SELECT}
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN shops s ON p.shop_id = s.id
       WHERE p.id = ?`,
      [productId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produk tidak ditemukan.',
      });
    }

    // Ambil array gambar tambahan dari product_images, urut sort_order
    const [imageRows] = await pool.execute(
      'SELECT image_url FROM product_images WHERE product_id = ? ORDER BY sort_order ASC',
      [productId]
    );

    const product = {
      ...rows[0],
      is_mall: Boolean(rows[0].is_mall),
      images: imageRows.map((r) => r.image_url),
    };

    return res.status(200).json({
      success: true,
      message: 'Detail produk berhasil diambil.',
      data: product,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllProducts, getProductById };
