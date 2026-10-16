// Routing pesanan
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { createOrder, getOrderSummary, getOrders, getOrderById, payOrder, cancelOrder, advanceOrder } = require('../controllers/orderController');

// Rute statis HARUS didefinisikan sebelum rute dinamis /:id
router.post('/',             auth, createOrder);
router.get('/summary',       auth, getOrderSummary);
router.get('/',              auth, getOrders);
router.get('/:id',           auth, getOrderById);
router.put('/:id/pay',       auth, payOrder);
router.put('/:id/cancel',    auth, cancelOrder);
router.put('/:id/advance',   auth, advanceOrder);

module.exports = router;


