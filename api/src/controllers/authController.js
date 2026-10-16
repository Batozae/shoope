// Controller autentikasi (register, login, getMe)
const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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

    return res.status(201).json({
      success: true,
      message: 'Registrasi berhasil.',
      data: {
        id: result.insertId,
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

module.exports = { register, login, getMe };
