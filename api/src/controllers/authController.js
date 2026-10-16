// Controller autentikasi (register, login, getMe, updateMe)
const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { createNotification } = require('../utils/notify');

/**
 * Registrasi user baru
 */
const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    // Validasi input wajib
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Field name, email, dan password wajib diisi.',
      });
    }

    // Validasi panjang password minimal 6 karakter
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password minimal 6 karakter.',
      });
    }

    // Cek apakah email sudah terdaftar
    const [existingUsers] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Email sudah terdaftar.',
      });
    }

    // Hash password sebelum disimpan
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Simpan user baru ke database
    const [result] = await pool.execute(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, passwordHash]
    );

    const userId = result.insertId;

    // Buat 2 notifikasi sambutan setelah register berhasil
    await createNotification(
      pool,
      userId,
      'promo',
      'Selamat Datang di Shoope! 🎉',
      'Nikmati ribuan produk pilihan dengan harga terbaik. Yuk, mulai belanja sekarang!'
    );
    await createNotification(
      pool,
      userId,
      'info',
      'Akun Anda Berhasil Dibuat',
      `Halo ${name}, akun Shoope Anda sudah aktif. Lengkapi profil dan tambahkan alamat pengiriman untuk pengalaman belanja yang lebih mudah.`
    );

    return res.status(201).json({
      success: true,
      message: 'Registrasi berhasil.',
      data: {
        id: userId,
        name,
        email,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login user dan generate JWT
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Validasi input wajib
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Field email dan password wajib diisi.',
      });
    }

    // Cari user berdasarkan email
    const [users] = await pool.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    const user = users[0];

    // Bandingkan password dengan hash
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah.',
      });
    }

    // Buat token JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Login berhasil.',
      data: {
        token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          avatar_url: user.avatar_url,
          created_at: user.created_at,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Ambil data user yang sedang login
 */
const getMe = async (req, res, next) => {
  try {
    // Ambil id dari token yang sudah diverifikasi
    const userId = req.user.id;

    // Query user tanpa field password_hash
    const [users] = await pool.execute(
      'SELECT id, name, email, phone, avatar_url, created_at FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Data user berhasil diambil.',
      data: users[0],
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Perbarui profil user (name, phone, avatar_url opsional)
 */
const updateMe = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { name, phone, avatar_url } = req.body;

    // Minimal name atau phone harus ada
    if (!name && !phone && avatar_url === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Minimal satu field (name, phone, atau avatar_url) harus diisi.',
      });
    }

    // Bangun SET dinamis hanya untuk field yang dikirim
    const fields = [];
    const params = [];

    if (name !== undefined) {
      if (!name.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Name tidak boleh kosong.',
        });
      }
      fields.push('name = ?');
      params.push(name.trim());
    }
    if (phone !== undefined) {
      fields.push('phone = ?');
      params.push(phone);
    }
    if (avatar_url !== undefined) {
      fields.push('avatar_url = ?');
      params.push(avatar_url);
    }

    params.push(userId);

    await pool.execute(
      `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
      params
    );

    // Kembalikan data terbaru tanpa password_hash
    const [rows] = await pool.execute(
      'SELECT id, name, email, phone, avatar_url, created_at FROM users WHERE id = ?',
      [userId]
    );

    return res.status(200).json({
      success: true,
      message: 'Profil berhasil diperbarui.',
      data: rows[0],
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { register, login, getMe, updateMe };
