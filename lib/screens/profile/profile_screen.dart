import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/ui.dart';
import '../cart/cart_screen.dart';
import '../order/order_list_screen.dart';
import 'settings_screen.dart';

// Layar Profil Pengguna (Saya) bergaya Shopee
class ProfileScreen extends StatefulWidget {
  final ValueNotifier<int>? tabSignal;

  const ProfileScreen({
    super.key,
    this.tabSignal,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OrderService _orderService = OrderService();
  OrderSummary _summary = const OrderSummary();

  @override
  void initState() {
    super.initState();
    widget.tabSignal?.addListener(_onTabSignalChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  @override
  void dispose() {
    widget.tabSignal?.removeListener(_onTabSignalChanged);
    super.dispose();
  }

  void _onTabSignalChanged() {
    // Muat ulang ringkasan pesanan saat tab Saya (indeks 3) dipilih
    if (widget.tabSignal?.value == 3) {
      _loadSummary();
    }
  }

  // Muat ulang data ringkasan pesanan dan jumlah keranjang
  Future<void> _loadSummary() async {
    try {
      context.read<CartProvider>().refreshCount();
      final summary = await _orderService.getOrderSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
        });
      }
    } catch (_) {
      // Abaikan kegagalan refresh ringkasan
    }
  }

  // Buka daftar pesanan dengan tab awal tertentu dan segarkan data setelah kembali
  void _openOrders(int initialTab) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => OrderListScreen(initialTab: initialTab),
      ),
    )
        .then((_) {
      _loadSummary();
    });
  }

  // Item aksi pada kartu pesanan saya
  Widget _buildOrderActionItem({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              count > 0
                  ? Badge(
                      label: Text(
                        '$count',
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.red,
                      child: Icon(icon, size: 26, color: Colors.black87),
                    )
                  : Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Item pada kartu dompet saya
  Widget _buildWalletItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: AppTheme.primaryColor),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Item pada kartu keuangan (grid 2x2)
  Widget _buildFinanceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Oranye
              Container(
                color: AppTheme.primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Baris aksi atas (Pengaturan, Keranjang, Chat)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                              ),
                              tooltip: 'Pengaturan',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cartProv, _) {
                                final count = cartProv.cartCount;
                                final cartIcon = const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                );

                                return IconButton(
                                  icon: count > 0
                                      ? Badge(
                                          label: Text('$count'),
                                          backgroundColor: Colors.white,
                                          textColor: AppTheme.primaryColor,
                                          child: cartIcon,
                                        )
                                      : cartIcon,
                                  tooltip: 'Keranjang Belanja',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const CartScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                              ),
                              tooltip: 'Chat',
                              onPressed: () => showComingSoon(context),
                            ),
                          ],
                        ),
                      ),

                      // Informasi Pengguna
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.person,
                                size: 38,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Pengguna',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 11,
                                              color: Colors.amberAccent,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Classic',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '0 Mengikuti  0 Pengikut',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Banner VIP Statis
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFEEBA)),
                ),
                child: InkWell(
                  onTap: () => showComingSoon(context),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFD39E00),
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Dapatkan Extra Diskon 20% Setiap Hari',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF856404),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFF856404),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Kartu Pesanan Saya
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      // Baris Judul & Riwayat
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pesanan Saya',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () => _openOrders(0),
                              child: Row(
                                children: [
                                  Text(
                                    'Lihat Riwayat Pesanan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey[200],
                      ),

                      // 4 Ikon Status Pesanan dengan badge
                      Row(
                        children: [
                          _buildOrderActionItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Belum Bayar',
                            count: _summary.pending,
                            onTap: () => _openOrders(1),
                          ),
                          _buildOrderActionItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Dikemas',
                            count: _summary.paid,
                            onTap: () => _openOrders(2),
                          ),
                          _buildOrderActionItem(
                            icon: Icons.local_shipping_outlined,
                            label: 'Dikirim',
                            count: _summary.shipped,
                            onTap: () => _openOrders(3),
                          ),
                          _buildOrderActionItem(
                            icon: Icons.star_outline,
                            label: 'Beri Penilaian',
                            count: _summary.completed,
                            onTap: () => _openOrders(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Kartu Statis Ringkas: Pulsa, Tagihan & Tiket dan ShopeeFood
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => showComingSoon(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_android,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pulsa, Tagihan & Tiket',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey[200]),
                    Expanded(
                      child: InkWell(
                        onTap: () => showComingSoon(context),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ShopeeFood',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Kartu Dompet Saya
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dompet Saya',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildWalletItem(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'ShopeePay',
                            subtitle: 'Rp0',
                            onTap: () => showComingSoon(context),
                          ),
                          _buildWalletItem(
                            icon: Icons.monetization_on_outlined,
                            title: 'Koin Shopee',
                            subtitle: '0 Koin',
                            onTap: () => showComingSoon(context),
                          ),
                          _buildWalletItem(
                            icon: Icons.confirmation_number_outlined,
                            title: 'Voucher Saya',
                            subtitle: '0 Voucher',
                            onTap: () => showComingSoon(context),
                          ),
                          _buildWalletItem(
                            icon: Icons.card_giftcard_outlined,
                            title: 'Bonus Saldo',
                            subtitle: 'Klaim',
                            onTap: () => showComingSoon(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Kotak SPinjam
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: AppTheme.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SPinjam',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Pinjaman tunai s/d Rp50.000.000',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => showComingSoon(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Cek Limit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Kartu Keuangan
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keuangan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFinanceItem(
                              icon: Icons.payment,
                              title: 'SPayLater',
                              subtitle: 'Aktifkan sekarang',
                              onTap: () => showComingSoon(context),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey[200],
                          ),
                          Expanded(
                            child: _buildFinanceItem(
                              icon: Icons.request_quote_outlined,
                              title: 'SPinjam',
                              subtitle: 'Dapatkan limit',
                              onTap: () => showComingSoon(context),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey[200],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFinanceItem(
                              icon: Icons.account_balance,
                              title: 'SeaBank',
                              subtitle: 'Bunga s/d 6%',
                              onTap: () => showComingSoon(context),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey[200],
                          ),
                          Expanded(
                            child: _buildFinanceItem(
                              icon: Icons.security,
                              title: 'Asuransi',
                              subtitle: 'Proteksi pesanan',
                              onTap: () => showComingSoon(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
