// Controller alamat pengiriman
const pool = require('../config/db');

/**
 * Ambil semua alamat milik user yang login
 */
const getAddresses = async (req, res, next) => {
  try {
    const [addresses] = await pool.execute(
      'SELECT id, recipient_name, phone, full_address, city, postal_code, is_default FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC',
      [req.user.id]
    );

    return res.status(200).json({
      success: true,
      message: 'Daftar alamat berhasil diambil.',
      data: addresses,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Tambah alamat baru
 */
const createAddress = async (req, res, next) => {
  try {
    const { recipient_name, phone, full_address, city, postal_code, is_default } = req.body;

    // Validasi field wajib
    if (!recipient_name || !phone || !full_address || !city || !postal_code) {
      return res.status(400).json({
        success: false,
        message: 'Field recipient_name, phone, full_address, city, dan postal_code wajib diisi.',
      });
    }

    const userId = req.user.id;
    const setDefault = is_default === true || is_default === 1;

    // Jika alamat baru dijadikan default, set semua alamat lain menjadi non-default
    if (setDefault) {
      await pool.execute(
        'UPDATE addresses SET is_default = FALSE WHERE user_id = ?',
        [userId]
      );
    }

    const [result] = await pool.execute(
      'INSERT INTO addresses (user_id, recipient_name, phone, full_address, city, postal_code, is_default) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, recipient_name, phone, full_address, city, postal_code, setDefault]
    );

    return res.status(201).json({
      success: true,
      message: 'Alamat berhasil ditambahkan.',
      data: {
        id: result.insertId,
        recipient_name,
        phone,
        full_address,
        city,
        postal_code,
        is_default: setDefault,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Hapus alamat (hanya milik user; tolak jika sudah dipakai di orders)
 */
const deleteAddress = async (req, res, next) => {
  try {
    const addressId = parseInt(req.params.id, 10);
    const userId = req.user.id;

    // Pastikan alamat milik user
    const [rows] = await pool.execute(
      'SELECT id FROM addresses WHERE id = ? AND user_id = ?',
      [addressId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Alamat tidak ditemukan.',
      });
    }

    // Cek apakah alamat sudah dipakai di pesanan
    const [orderRows] = await pool.execute(
      'SELECT id FROM orders WHERE address_id = ? LIMIT 1',
      [addressId]
    );

    if (orderRows.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Alamat tidak bisa dihapus karena sudah digunakan dalam pesanan.',
      });
    }

    await pool.execute('DELETE FROM addresses WHERE id = ?', [addressId]);

    return res.status(200).json({
      success: true,
      message: 'Alamat berhasil dihapus.',
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAddresses, createAddress, deleteAddress };

