// Routing alamat pengiriman
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getAddresses, createAddress, deleteAddress } = require('../controllers/addressController');

router.get('/', auth, getAddresses);
router.post('/', auth, createAddress);
router.delete('/:id', auth, deleteAddress);

module.exports = router;

