// Setup aplikasi Express
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./config/db');
const authRoutes          = require('./routes/authRoutes');
const categoryRoutes      = require('./routes/categoryRoutes');
const productRoutes       = require('./routes/productRoutes');
const addressRoutes       = require('./routes/addressRoutes');
const cartRoutes          = require('./routes/cartRoutes');
const orderRoutes         = require('./routes/orderRoutes');
const notificationRoutes  = require('./routes/notificationRoutes');
const errorHandler        = require('./middleware/errorHandler');

const app = express();

// Middleware bawaan
app.use(cors());
app.use(express.json());

// Endpoint health check untuk cek server & koneksi database
app.get('/api/health', async (req, res) => {
  try {
    await pool.execute('SELECT 1');
    return res.status(200).json({
      success: true,
      message: 'Server berjalan & database terhubung.',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server berjalan, tapi database tidak terhubung.',
    });
  }
});

// Routing API
app.use('/api/auth',          authRoutes);
app.use('/api/categories',    categoryRoutes);
app.use('/api/products',      productRoutes);
app.use('/api/addresses',     addressRoutes);
app.use('/api/cart',          cartRoutes);
app.use('/api/orders',        orderRoutes);
app.use('/api/notifications', notificationRoutes);

// Penanganan error global (harus di paling akhir)
app.use(errorHandler);

module.exports = app;
