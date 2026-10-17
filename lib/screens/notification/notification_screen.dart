import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/app_notification.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/api_client.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../cart/cart_screen.dart';
import '../order/order_list_screen.dart';

// Layar Notifikasi Pengguna
class NotificationScreen extends StatefulWidget {
  final ValueNotifier<int>? tabSignal;

  const NotificationScreen({
    super.key,
    this.tabSignal,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPermissionBanner = true;

  // Daftar tab notifikasi
  static const List<Map<String, String?>> _tabs = [
    {'label': 'Pilihan Teratas', 'category': null},
    {'label': 'Promo', 'category': 'promo'},
    {'label': 'Pesanan', 'category': 'pesanan'},
    {'label': 'Info', 'category': 'info'},
  ];

  // Global key untuk memicu refresh pada setiap tab view
  final List<GlobalKey<_NotificationTabViewState>> _tabKeys = [
    GlobalKey<_NotificationTabViewState>(),
    GlobalKey<_NotificationTabViewState>(),
    GlobalKey<_NotificationTabViewState>(),
    GlobalKey<_NotificationTabViewState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Pantau sinyal perubahan tab dari shell jika diberikan
    widget.tabSignal?.addListener(_onTabSignalChanged);

    // Muat jumlah unread dan keranjang di awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  @override
  void dispose() {
    widget.tabSignal?.removeListener(_onTabSignalChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSignalChanged() {
    if (widget.tabSignal?.value == 2) {
      _refreshAllData();
    }
  }

  Future<void> _refreshAllData() async {
    context.read<NotificationProvider>().refreshUnreadCount();
    context.read<CartProvider>().refreshCount();
    final currentKey = _tabKeys[_tabController.index];
    currentKey.currentState?.reloadNotifications();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Segera hadir'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleMarkAllRead() async {
    try {
      await context.read<NotificationProvider>().markAllRead();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sudah dibaca.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Reload semua tab
      for (final key in _tabKeys) {
        key.currentState?.reloadNotifications();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red[700]),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal menandai notifikasi.'), backgroundColor: Colors.red[700]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // Ikon Keranjang Belanja dengan badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartProvider.cartCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          cartProvider.cartCount > 99 ? '99+' : '${cartProvider.cartCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Ikon Chat
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: AppTheme.primaryColor),
            onPressed: _showComingSoon,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner izin notifikasi kuning muda
          if (_showPermissionBanner)
            Container(
              color: const Color(0xFFFFF9E6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: Color(0xFFF57C00), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Izinkan notifikasi untuk dapatkan info status pesanan, promo, dan info menarik lainnya.',
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.25),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _showPermissionBanner = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Baris "Update Terbaru" dan tombol "Tandai Sudah Dibaca"
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Terbaru',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _handleMarkAllRead,
                  child: const Text(
                    'Tandai Sudah Dibaca',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // TabBar filter kategori
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.black87,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;

                // Tab pertama memiliki badge unread count jika ada
                if (index == 0 && unreadCount > 0) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tab['label']!),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Tab(text: tab['label']);
              }).toList(),
            ),
          ),

          // Konten Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                return _NotificationTabView(
                  key: _tabKeys[index],
                  category: tab['category'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget tampilan isi tiap tab notifikasi
class _NotificationTabView extends StatefulWidget {
  final String? category;

  const _NotificationTabView({
    super.key,
    required this.category,
  });

  @override
  State<_NotificationTabView> createState() => _NotificationTabViewState();
}

class _NotificationTabViewState extends State<_NotificationTabView>
    with AutomaticKeepAliveClientMixin {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void reloadNotifications() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _notificationService.getNotifications(category: widget.category);
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat notifikasi.';
          _isLoading = false;
        });
      }
    }
  }

  // Format tanggal: jika hari ini "HH:mm", selain itu "dd/MM/yyyy"
  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    final local = parsed.toLocal();
    final now = DateTime.now();
    final isToday = local.year == now.year && local.month == now.month && local.day == now.day;

    if (isToday) {
      return DateFormat('HH:mm').format(local);
    } else {
      return DateFormat('dd/MM/yyyy').format(local);
    }
  }

  // Ikon & warna bulat berdasarkan kategori
  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    Color bgColor;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'promo':
        iconData = Icons.local_offer_outlined;
        bgColor = const Color(0xFFFFECE7);
        iconColor = AppTheme.primaryColor;
        break;
      case 'pesanan':
        iconData = Icons.local_shipping_outlined;
        bgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1E88E5);
        break;
      case 'info':
      default:
        iconData = Icons.info_outline;
        bgColor = const Color(0xFFFFF8E1);
        iconColor = const Color(0xFFFFA000);
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: bgColor,
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  // Aksi saat item notifikasi diklik
  Future<void> _handleItemTap(AppNotification notif) async {
    if (!notif.isRead) {
      setState(() {
        notif.isRead = true;
      });
      try {
        await context.read<NotificationProvider>().markRead(notif.id);
      } catch (_) {
        // Abaikan error background mark read
      }
    }

    if (notif.category.toLowerCase() == 'pesanan' && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrderListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
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
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              'Notifikasi dan promo spesial akan muncul di sini.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadNotifications,
      child: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          // Latar kemerahan sangat muda jika belum dibaca, putih jika sudah dibaca
          final itemBgColor = notif.isRead ? Colors.white : const Color(0xFFFFF8F6);

          return InkWell(
            onTap: () => _handleItemTap(notif),
            child: Container(
              color: itemBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryIcon(notif.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(notif.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
