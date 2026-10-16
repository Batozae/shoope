// Controller notifikasi
const pool = require('../config/db');

// Nilai valid untuk filter category
const VALID_CATEGORIES = ['promo', 'pesanan', 'info'];

/**
 * Hitung notifikasi belum dibaca milik user
 */
const getUnreadCount = async (userId) => {
  const [rows] = await pool.execute(
    'SELECT COUNT(*) AS count FROM notifications WHERE user_id = ? AND is_read = FALSE',
    [userId]
  );
  return rows[0].count;
};

/**
 * GET /api/notifications
 * Query opsional: category (promo|pesanan|info)
 * Response: { items: [...], unread_count }
 */
const getNotifications = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { category } = req.query;

    // Bangun WHERE dinamis
    const conditions = ['user_id = ?'];
    const params = [userId];

    if (category) {
      // Validasi value category dari whitelist
      if (!VALID_CATEGORIES.includes(category)) {
        return res.status(400).json({
          success: false,
          message: `Category tidak valid. Pilihan: ${VALID_CATEGORIES.join(', ')}.`,
        });
      }
      conditions.push('category = ?');
      params.push(category);
    }

    const where = conditions.join(' AND ');

    const [items] = await pool.execute(
      `SELECT id, category, title, body, image_url, is_read, created_at
       FROM notifications
       WHERE ${where}
       ORDER BY created_at DESC`,
      params
    );

    const unreadCount = await getUnreadCount(userId);

    return res.status(200).json({
      success: true,
      message: 'Daftar notifikasi berhasil diambil.',
      data: {
        items,
        unread_count: unreadCount,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/notifications/unread-count
 */
const getUnreadCountEndpoint = async (req, res, next) => {
  try {
    const unreadCount = await getUnreadCount(req.user.id);

    return res.status(200).json({
      success: true,
      message: 'Jumlah notifikasi belum dibaca berhasil diambil.',
      data: { unread_count: unreadCount },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/notifications/read-all
 * Tandai semua notifikasi milik user sebagai dibaca
 */
const markAllRead = async (req, res, next) => {
  try {
    await pool.execute(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE',
      [req.user.id]
    );

    return res.status(200).json({
      success: true,
      message: 'Semua notifikasi ditandai sudah dibaca.',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/notifications/:id/read
 * Tandai satu notifikasi sebagai dibaca (hanya milik user)
 */
const markOneRead = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notifId = parseInt(req.params.id, 10);

    // Pastikan notifikasi milik user
    const [rows] = await pool.execute(
      'SELECT id FROM notifications WHERE id = ? AND user_id = ?',
      [notifId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notifikasi tidak ditemukan.',
      });
    }

    await pool.execute(
      'UPDATE notifications SET is_read = TRUE WHERE id = ?',
      [notifId]
    );

    return res.status(200).json({
      success: true,
      message: 'Notifikasi ditandai sudah dibaca.',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getNotifications, getUnreadCountEndpoint, markAllRead, markOneRead };

