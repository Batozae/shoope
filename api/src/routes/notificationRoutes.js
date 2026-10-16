// Routing notifikasi
const express = require('express');
const router  = express.Router();
const auth    = require('../middleware/auth');
const {
  getNotifications,
  getUnreadCountEndpoint,
  markAllRead,
  markOneRead,
} = require('../controllers/notificationController');

// Definisikan rute statis SEBELUM rute dinamis /:id
router.get('/',              auth, getNotifications);
router.get('/unread-count',  auth, getUnreadCountEndpoint);
router.put('/read-all',      auth, markAllRead);
router.put('/:id/read',      auth, markOneRead);

module.exports = router;

