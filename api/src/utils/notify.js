// Utilitas untuk membuat notifikasi
// executor: pool biasa atau conn transaksi — keduanya punya method execute()

/**
 * Sisipkan satu baris notifikasi ke tabel notifications.
 * @param {object} executor - pool atau conn (transaksi)
 * @param {number} userId
 * @param {'promo'|'pesanan'|'info'} category
 * @param {string} title
 * @param {string} body
 * @param {string|null} [imageUrl]
 */
const createNotification = async (executor, userId, category, title, body, imageUrl = null) => {
  await executor.execute(
    'INSERT INTO notifications (user_id, category, title, body, image_url) VALUES (?, ?, ?, ?, ?)',
    [userId, category, title, body, imageUrl]
  );
};

module.exports = { createNotification };

