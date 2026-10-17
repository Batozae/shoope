import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'order_detail_screen.dart';

// Layar daftar pesanan pengguna dengan tab filter status
class OrderListScreen extends StatefulWidget {
  final int initialTab;

  const OrderListScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab konfigurasi: label dan status query
  static const List<Map<String, String?>> _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Belum Bayar', 'status': 'pending'},
    {'label': 'Dikemas', 'status': 'paid'},
    {'label': 'Dikirim', 'status': 'shipped'},
    {'label': 'Selesai', 'status': 'completed'},
    {'label': 'Dibatalkan', 'status': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    final tabIndex = widget.initialTab.clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: tabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.black87,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((tab) => Tab(text: tab['label'])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return _OrderTabView(status: tab['status']);
        }).toList(),
      ),
    );
  }
}

// Widget tampilan per tab daftar pesanan
class _OrderTabView extends StatefulWidget {
  final String? status;

  const _OrderTabView({required this.status});

  @override
  State<_OrderTabView> createState() => _OrderTabViewState();
}

class _OrderTabViewState extends State<_OrderTabView>
    with AutomaticKeepAliveClientMixin {
  final OrderService _orderService = OrderService();

  List<OrderListItem> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Muat daftar pesanan sesuai filter status
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _orderService.getOrders(status: widget.status);
      if (mounted) {
        setState(() {
          _orders = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat pesanan.';
          _isLoading = false;
        });
      }
    }
  }

  // Aksi bayar pesanan
  Future<void> _payOrder(int id) async {
    try {
      await _orderService.payOrder(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil dikonfirmasi.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadOrders();
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
    }
  }

  // Aksi batalkan pesanan
  Future<void> _cancelOrder(int id) async {
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
      try {
        await _orderService.cancelOrder(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan.'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadOrders();
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
      }
    }
  }

  // Aksi majukan status (advance)
  Future<void> _advanceOrder(int id) async {
    try {
      await _orderService.advanceOrder(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan berhasil diperbarui.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadOrders();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadOrders, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 68, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text('Pesanan kamu akan muncul di sini.', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  // Kartu pesanan pada daftar
  Widget _buildOrderCard(OrderListItem order) {
    final color = statusColor(order.status);

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id),
          ),
        );
        _loadOrders();
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: "Pesanan #id" dan label status berwarna
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      'Pesanan #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  statusLabel(order.status),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Gambar + Nama produk pertama + keterangan n produk lainnya
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: order.firstProductImage != null && order.firstProductImage!.isNotEmpty
                      ? Image.network(
                          order.firstProductImage!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 24),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
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
                        order.firstProductName ?? 'Produk Pesanan',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                      if (order.itemCount > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${order.itemCount - 1} produk lainnya',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Baris Total Pesanan & Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemCount} produk',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    const Text('Total Pesanan: ', style: TextStyle(fontSize: 12)),
                    Text(
                      formatRupiah(order.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Tombol Aksi jika ada
            if (order.status != 'completed' && order.status != 'cancelled') ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == 'pending') ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[300]!),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _cancelOrder(order.id),
                      child: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _payOrder(order.id),
                      child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  if (order.status == 'paid') ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _advanceOrder(order.id),
                      child: const Text('Proses Pengiriman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  if (order.status == 'shipped') ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _advanceOrder(order.id),
                      child: const Text('Pesanan Diterima', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

