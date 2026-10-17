import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';

// Layar rincian detail pesanan
class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();

  OrderDetail? _order;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  // Muat data detail pesanan dari API
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _orderService.getOrderDetail(widget.orderId);
      if (mounted) {
        setState(() {
          _order = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat rincian pesanan.';
          _isLoading = false;
        });
      }
    }
  }

  // Format tanggal pesanan
  String _formatDateTime(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    final localDate = parsed.toLocal();
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(localDate);
  }

  // Aksi bayar pesanan
  Future<void> _handlePayOrder() async {
    setState(() => _isProcessingAction = true);
    try {
      await _orderService.payOrder(widget.orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil dikonfirmasi.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadOrderDetail();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red[700]),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal memproses pembayaran.'), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  // Aksi batalkan pesanan
  Future<void> _handleCancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah kamu yakin ingin membatalkan pesanan ini? Stok produk akan dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0011B)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessingAction = true);
      try {
        await _orderService.cancelOrder(widget.orderId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan.'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadOrderDetail();
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red[700]),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Gagal membatalkan pesanan.'), backgroundColor: Colors.red[700]),
        );
      } finally {
        if (mounted) setState(() => _isProcessingAction = false);
      }
    }
  }

  // Aksi majukan status pesanan (paid -> shipped -> completed)
  Future<void> _handleAdvanceOrder() async {
    setState(() => _isProcessingAction = true);
    try {
      await _orderService.advanceOrder(widget.orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan berhasil diperbarui.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadOrderDetail();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red[700]),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal memperbarui status pesanan.'), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Rincian Pesanan'), backgroundColor: Colors.white, elevation: 0.5),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_errorMessage != null || _order == null) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Rincian Pesanan'), backgroundColor: Colors.white, elevation: 0.5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'Pesanan tidak ditemukan.', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadOrderDetail, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final color = statusColor(order.status);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rincian Pesanan'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: _loadOrderDetail,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Banner status pesanan
              Container(
                color: color,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pesanan #${order.id}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Info nomor pesanan dan tanggal
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nomor Pesanan: #${order.id}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(_formatDateTime(order.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 3. Kartu Alamat Pengiriman
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18, color: AppTheme.primaryColor),
                        SizedBox(width: 6),
                        Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${order.address.recipientName} (${order.address.phone})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      '${order.address.fullAddress}, ${order.address.city}, ${order.address.postalCode}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 4. Daftar Produk
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daftar Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Divider(height: 16),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, size: 24),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.inventory_2_outlined, size: 24),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, height: 1.3),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatRupiah(item.priceAtPurchase),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'x${item.quantity}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 5. Metode Pembayaran & Rincian Total
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Metode Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(order.paymentMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          formatRupiah(order.totalPrice),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionButtons(order),
    );
  }

  // Tombol aksi di bawah sesuai status
  Widget? _buildBottomActionButtons(OrderDetail order) {
    if (order.status == 'completed' || order.status == 'cancelled') {
      return null;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Status pending -> "Batalkan" dan "Bayar Sekarang"
            if (order.status == 'pending') ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[400]!),
                ),
                onPressed: _isProcessingAction ? null : _handleCancelOrder,
                child: const Text('Batalkan'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isProcessingAction ? null : _handlePayOrder,
                child: _isProcessingAction
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],

            // Status paid -> "Proses Pengiriman" (simulasi)
            if (order.status == 'paid') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isProcessingAction ? null : _handleAdvanceOrder,
                child: _isProcessingAction
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Proses Pengiriman', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],

            // Status shipped -> "Pesanan Diterima"
            if (order.status == 'shipped') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isProcessingAction ? null : _handleAdvanceOrder,
                child: _isProcessingAction
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Pesanan Diterima', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

