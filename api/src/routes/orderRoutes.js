// Routing pesanan
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { createOrder, getOrders, getOrderById, payOrder, cancelOrder } = require('../controllers/orderController');

router.post('/', auth, createOrder);
router.get('/', auth, getOrders);
router.get('/:id', auth, getOrderById);
router.put('/:id/pay', auth, payOrder);
router.put('/:id/cancel', auth, cancelOrder);

module.exports = router;

