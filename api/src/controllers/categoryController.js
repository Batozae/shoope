// Controller kategori produk
const pool = require('../config/db');

/**
 * Ambil semua kategori
 * GET /api/categories
 */
const getAllCategories = async (req, res, next) => {
  try {
    const [categories] = await pool.execute(
      'SELECT id, name, icon_url FROM categories ORDER BY id ASC'
    );

    return res.status(200).json({
      success: true,
      message: 'Daftar kategori berhasil diambil.',
      data: categories,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAllCategories };

