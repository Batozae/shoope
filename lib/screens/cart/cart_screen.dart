import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/product_card.dart';
import '../checkout/checkout_screen.dart';
import '../product/product_detail_screen.dart';

// Layar Keranjang Belanja utama bergaya Shopee
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ProductService _productService = ProductService();

  bool _isEditMode = false;
  List<Product> _recommendations = [];
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
      _loadRecommendations();
    });
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final result = await _productService.getProducts(
        sort: 'popular',
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _recommendations = result.items;
          _isLoadingRecommendations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Segera hadir'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Dialog konfirmasi hapus item terpilih
  Future<void> _confirmDeleteSelected(CartProvider cartProvider) async {
    final selectedIds = cartProvider.selectedIds.toList();
    if (selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Apakah kamu yakin ingin menghapus ${selectedIds.length} produk dari keranjang?',
          style: const TextStyle(fontSize: AppDimens.fontTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD0011B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await cartProvider.removeItems(selectedIds);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus dari keranjang.'),
            duration: Duration(seconds: 2),
          ),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red[700]),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghapus produk.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Keranjang Saya (${cartProvider.cartCount})',
          style: const TextStyle(
            fontSize: AppDimens.fontHeader,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Tombol Ubah / Selesai
          if (cartProvider.allItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              child: Text(
                _isEditMode ? 'Selesai' : 'Ubah',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimens.fontTitle,
                ),
              ),
            ),
          // Ikon Chat
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: AppTheme.primaryColor, size: AppDimens.iconLg),
            onPressed: _showComingSoon,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await Future.wait([cartProvider.fetchCart(), _loadRecommendations()]);
        },
        child: _buildBody(cartProvider),
      ),
      bottomNavigationBar: cartProvider.allItems.isEmpty
          ? null
          : _buildBottomBar(cartProvider),
    );
  }

  Widget _buildBody(CartProvider cartProvider) {
    if (cartProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (cartProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cartProvider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => cartProvider.fetchCart(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final isCartEmpty = cartProvider.allItems.isEmpty;

    return CustomScrollView(
      slivers: [
        // Jika keranjang kosong
        if (isCartEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: AppDimens.space24),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  const Text(
                    'Keranjangmu masih kosong',
                    style: TextStyle(
                      fontSize: AppDimens.fontPrice,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space24,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Belanja Sekarang'),
                  ),
                ],
              ),
            ),
          )
        else
          // Daftar kartu per toko
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final shop = cartProvider.shops[index];
              return _buildShopCard(shop, cartProvider);
            }, childCount: cartProvider.shops.length),
          ),

        // Bagian Rekomendasi "Kamu Mungkin Juga Suka"
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: AppDimens.space12),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: AppDimens.space12),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: AppTheme.primaryColor,
                  size: AppDimens.iconMd,
                ),
                SizedBox(width: 6),
                Text(
                  'Kamu Mungkin Juga Suka',
                  style: TextStyle(
                    fontSize: AppDimens.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isLoadingRecommendations)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.space24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.space8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                mainAxisSpacing: AppDimens.space8,
                crossAxisSpacing: AppDimens.space8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = _recommendations[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                );
              }, childCount: _recommendations.length),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80), // Ruang untuk bottom bar
        ),
      ],
    );
  }

  // Kartu satu toko beserta seluruh itemnya
  Widget _buildShopCard(CartShop shop, CartProvider cartProvider) {
    final allShopSelected =
        shop.items.isNotEmpty &&
        shop.items.every((i) => cartProvider.selectedIds.contains(i.productId));

    return Container(
      margin: const EdgeInsets.only(top: AppDimens.space8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toko
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
            child: Row(
              children: [
                Checkbox(
                  activeColor: AppTheme.primaryColor,
                  value: allShopSelected,
                  onChanged: (_) => cartProvider.toggleShop(shop.shopId),
                ),
                if (shop.isMall) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0011B),
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                    ),
                    child: const Text(
                      'Mall',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    shop.shopName ?? 'Toko Shoope',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimens.fontBody,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, size: AppDimens.iconMd, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1),

          // Daftar Item Toko
          ...shop.items.map((item) => _buildCartItemTile(item, cartProvider)),

          // Baris Voucher Diskon Toko
          InkWell(
            onTap: _showComingSoon,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: AppDimens.iconSm,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: AppDimens.space8),
                  Expanded(
                    child: Text(
                      'Tersedia Voucher Diskon s/d Rp30RB',
                      style: TextStyle(fontSize: AppDimens.fontCaption, color: Colors.black87),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: AppDimens.iconSm, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan satu item produk di keranjang
  Widget _buildCartItemTile(CartItem item, CartProvider cartProvider) {
    final isSelected = cartProvider.selectedIds.contains(item.productId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox Item
          Checkbox(
            activeColor: AppTheme.primaryColor,
            value: isSelected,
            onChanged: (_) => cartProvider.toggleItem(item.productId),
          ),

          // Gambar Produk 80x80
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: AppDimens.iconLg,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Detail Nama, Harga, dan Stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: AppDimens.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Harga Oranye
                    Text(
                      formatRupiah(item.price),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: AppDimens.fontBody,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Stepper Jumlah
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Kurang (-)
                          InkWell(
                            onTap: item.quantity > 1
                                ? () async {
                                    try {
                                      await cartProvider.updateQuantity(
                                        item.productId,
                                        item.quantity - 1,
                                      );
                                    } on ApiException catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(e.message),
                                              backgroundColor: Colors.red[700],
                                            ),
                                          );
                                    }
                                  }
                                : null,
                            child: Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              color: item.quantity > 1
                                  ? Colors.white
                                  : Colors.grey[100],
                              child: const Icon(Icons.remove, size: AppDimens.iconSm),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          // Tombol Tambah (+)
                          InkWell(
                            onTap: item.quantity < item.stock
                                ? () async {
                                    try {
                                      await cartProvider.updateQuantity(
                                        item.productId,
                                        item.quantity + 1,
                                      );
                                    } on ApiException catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(e.message),
                                              backgroundColor: Colors.red[700],
                                            ),
                                          );
                                    }
                                  }
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Stok tersisa ${item.stock}',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                            child: Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              color: item.quantity < item.stock
                                  ? Colors.white
                                  : Colors.grey[100],
                              child: const Icon(Icons.add, size: AppDimens.iconSm),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom bar tetap di bagian bawah
  Widget _buildBottomBar(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Baris Voucher Shopee Statis
          InkWell(
            onTap: _showComingSoon,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: AppDimens.iconSm,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: AppDimens.space8),
                  Text(
                    'Voucher Shoope',
                    style: TextStyle(fontSize: AppDimens.fontCaption, fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  Text(
                    'Gunakan/ masukkan kode',
                    style: TextStyle(fontSize: AppDimens.fontCaption, color: Colors.grey),
                  ),
                  Icon(Icons.chevron_right, size: AppDimens.iconSm, color: Colors.grey),
                ],
              ),
            ),
          ),

          // Baris Aksi Checkout / Hapus
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: 6),
            child: Row(
              children: [
                // Checkbox "Semua"
                Checkbox(
                  activeColor: AppTheme.primaryColor,
                  value: cartProvider.allSelected,
                  onChanged: (_) => cartProvider.toggleAll(),
                ),
                const Text(
                  'Semua',
                  style: TextStyle(fontSize: AppDimens.fontBody, fontWeight: FontWeight.w500),
                ),
                const Spacer(),

                // Mode Normal (Tampilkan Total & Tombol Checkout)
                if (!_isEditMode) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Total: ', style: TextStyle(fontSize: AppDimens.fontCaption)),
                          Text(
                            formatRupiah(cartProvider.selectedTotal),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: AppDimens.fontTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Hemat Rp0',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartProvider.selectedCount > 0
                          ? AppTheme.primaryColor
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space16,
                        vertical: AppDimens.space12,
                      ),
                    ),
                    onPressed: cartProvider.selectedCount > 0
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  productIds: cartProvider.selectedIds.toList(),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Checkout (${cartProvider.selectedCount})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimens.fontTitle),
                    ),
                  ),
                ] else ...[
                  // Mode Ubah (Tombol Hapus)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartProvider.selectedCount > 0
                          ? const Color(0xFFD0011B)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: AppDimens.space12,
                      ),
                    ),
                    onPressed: cartProvider.selectedCount > 0
                        ? () => _confirmDeleteSelected(cartProvider)
                        : null,
                    child: Text(
                      'Hapus (${cartProvider.selectedCount})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimens.fontTitle),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
