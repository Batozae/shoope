import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';

// Layar Beranda utama aplikasi Shoope dengan ukuran visual konsisten
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  final List<Product> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingProducts = false;
  bool _isLoadingMore = false;
  String? _productErrorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Deteksi scroll mendekati dasar untuk infinite scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore &&
          !_isLoadingProducts &&
          _currentPage < _totalPages) {
        _loadMoreProducts();
      }
    }
  }

  // Muat data awal kategori, produk, dan perbarui jumlah keranjang
  Future<void> _loadInitialData() async {
    context.read<CartProvider>().refreshCount();
    await Future.wait([_loadCategories(), _loadProducts(refresh: true)]);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _productService.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoadingProducts = true;
        _productErrorMessage = null;
        _currentPage = 1;
      });
    }

    try {
      final result = await _productService.getProducts(page: 1, limit: 10);
      if (mounted) {
        setState(() {
          _products.clear();
          _products.addAll(result.items);
          _totalPages = result.totalPages;
          _currentPage = 1;
          _isLoadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _productErrorMessage = 'Gagal memuat produk. Periksa koneksi Anda.';
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await _productService.getProducts(
        page: nextPage,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _products.addAll(result.items);
          _currentPage = nextPage;
          _totalPages = result.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // Buka halaman dan refresh keranjang saat kembali
  Future<void> _navigateTo(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) {
      context.read<CartProvider>().refreshCount();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () async {
          await _loadInitialData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header oranye pinned dengan kotak pencarian dan ikon aksi
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              expandedHeight: 0,
              toolbarHeight: 60,
              titleSpacing: AppDimens.pagePadding,
              title: Row(
                children: [
                  // Kotak pencarian putih
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _navigateTo(const SearchScreen());
                      },
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppTheme.primaryColor,
                              size: AppDimens.iconMd,
                            ),
                            const SizedBox(width: AppDimens.space8),
                            Expanded(
                              child: Text(
                                'Cari di Shoope...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: AppDimens.fontBody,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.grey,
                                size: AppDimens.iconMd,
                              ),
                              onPressed: _showComingSoon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.space8),

                  // Ikon Keranjang dengan badge
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: AppDimens.iconLg,
                            ),
                            onPressed: () {
                              _navigateTo(const CartScreen());
                            },
                          ),
                          if (cartProvider.cartCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    cartProvider.cartCount > 99
                                        ? '99+'
                                        : cartProvider.cartCount.toString(),
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: AppDimens.space12),

                  // Ikon Chat
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.chat_outlined,
                      color: Colors.white,
                      size: AppDimens.iconLg,
                    ),
                    onPressed: _showComingSoon,
                  ),
                ],
              ),
            ),

            // Strip 3 kolom statis
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimens.pagePadding,
                  vertical: AppDimens.space8,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: AppDimens.space12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStripItem(
                      Icons.account_balance_wallet_outlined,
                      'Cashback Saldo',
                    ),
                    Container(height: 20, width: 1, color: Colors.grey[300]),
                    _buildStripItem(
                      Icons.monetization_on_outlined,
                      'Klaim Koin',
                    ),
                    Container(height: 20, width: 1, color: Colors.grey[300]),
                    _buildStripItem(Icons.credit_card_outlined, 'SPinjam'),
                  ],
                ),
              ),
            ),

            // Banner Promo Statis
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimens.pagePadding,
                  vertical: AppDimens.space4,
                ),
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'PROMO SPESIAL HARI INI!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppDimens.fontPrice,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppDimens.space4),
                          Text(
                            'Gratis Ongkir & Diskon Hingga 90%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),

            // Baris menu ikon horizontal statis
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(top: AppDimens.space8),
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.pagePadding,
                  ),
                  child: Row(
                    children: [
                      _buildMenuItem(Icons.phone_android, 'Pulsa & Tagihan'),
                      _buildMenuItem(Icons.fastfood_outlined, 'ShopeeFood'),
                      _buildMenuItem(
                        Icons.workspace_premium_outlined,
                        'ShopeeVIP',
                      ),
                      _buildMenuItem(
                        Icons.confirmation_number_outlined,
                        'Bagi-Bagi\nVoucher',
                      ),
                      _buildMenuItem(
                        Icons.flash_on_outlined,
                        'Belanja\nInstant',
                      ),
                      _buildMenuItem(Icons.movie_filter_outlined, 'Non Drama'),
                    ],
                  ),
                ),
              ),
            ),

            // Baris kategori horizontal dari API
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: AppDimens.space8),
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.pagePadding,
                      ),
                      child: Text(
                        'KATEGORI',
                        style: TextStyle(
                          fontSize: AppDimens.fontBody,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoadingCategories)
                      const SizedBox(
                        height: 70,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_categories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: Text(
                          'Kategori tidak tersedia',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: Row(
                          children: _categories.map((cat) {
                            return GestureDetector(
                              onTap: () {
                                _navigateTo(
                                  SearchScreen(
                                    categoryId: cat.id,
                                    title: cat.name,
                                  ),
                                );
                              },
                              child: Container(
                                width: 72,
                                margin: const EdgeInsets.only(
                                  right: AppDimens.space8,
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          AppTheme.scaffoldBackgroundColor,
                                      child: const Icon(
                                        Icons.category_outlined,
                                        color: AppTheme.primaryColor,
                                        size: AppDimens.iconLg,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Judul "Rekomendasi Untukmu"
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: const Row(
                  children: [
                    Icon(
                      Icons.recommend,
                      color: AppTheme.primaryColor,
                      size: AppDimens.iconSm,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Rekomendasi Untukmu',
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

            // Grid produk 2 kolom atau indikator error/loading
            if (_isLoadingProducts)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            else if (_productErrorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        _productErrorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: AppDimens.space12),
                      ElevatedButton(
                        onPressed: () => _loadProducts(refresh: true),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space8,
                  vertical: AppDimens.space8,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    mainAxisSpacing: AppDimens.space8,
                    crossAxisSpacing: AppDimens.space8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        _navigateTo(ProductDetailScreen(productId: product.id));
                      },
                    );
                  }, childCount: _products.length),
                ),
              ),

              // Loading indikator di bagian bawah saat scroll memuat data lanjutan
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimens.space16,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStripItem(IconData icon, String label) {
    return InkWell(
      onTap: _showComingSoon,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimens.iconSm, color: AppTheme.primaryColor),
          const SizedBox(width: AppDimens.space4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppDimens.fontCaption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return InkWell(
      onTap: _showComingSoon,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFFFF0EC),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: AppDimens.iconMenu,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 10, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
