import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

// Layar Pencarian Produk dengan Filter Sort dan Kategori
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final int? categoryId;
  final String? title;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.categoryId,
    this.title,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;

  final List<Product> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Nilai sort: 'newest', 'popular', 'price_asc', 'price_desc'
  String _currentSort = 'newest';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController.addListener(_onScroll);
    _fetchProducts(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore && !_isLoading && _currentPage < _totalPages) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _fetchProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
      });
    }

    try {
      final query = _searchController.text.trim();
      final result = await _productService.getProducts(
        search: query.isNotEmpty ? query : null,
        categoryId: widget.categoryId,
        sort: _currentSort,
        page: 1,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _products.clear();
          _products.addAll(result.items);
          _totalPages = result.totalPages;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat produk.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = _searchController.text.trim();
      final nextPage = _currentPage + 1;
      final result = await _productService.getProducts(
        search: query.isNotEmpty ? query : null,
        categoryId: widget.categoryId,
        sort: _currentSort,
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

  // Ganti urutan sort
  void _changeSort(String sortKey) {
    if (_currentSort == sortKey) return;
    setState(() {
      _currentSort = sortKey;
    });
    _fetchProducts(reset: true);
  }

  // Toggle sort harga antara price_asc dan price_desc
  void _togglePriceSort() {
    if (_currentSort == 'price_asc') {
      _changeSort('price_desc');
    } else {
      _changeSort('price_asc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPriceActive = _currentSort == 'price_asc' || _currentSort == 'price_desc';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: widget.categoryId == null && (widget.initialQuery == null || widget.initialQuery!.isEmpty),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _fetchProducts(reset: true),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.title != null ? 'Cari di ${widget.title}...' : 'Cari di Shoope...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _fetchProducts(reset: true);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
            onChanged: (text) {
              setState(() {}); // Update ikon clear
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // Baris filter sort
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Terbaru
                Expanded(
                  child: _buildSortButton(
                    label: 'Terbaru',
                    isActive: _currentSort == 'newest',
                    onTap: () => _changeSort('newest'),
                  ),
                ),
                const SizedBox(width: 8),

                // Terlaris
                Expanded(
                  child: _buildSortButton(
                    label: 'Terlaris',
                    isActive: _currentSort == 'popular',
                    onTap: () => _changeSort('popular'),
                  ),
                ),
                const SizedBox(width: 8),

                // Harga (dengan ikon panah naik/turun)
                Expanded(
                  child: InkWell(
                    onTap: _togglePriceSort,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isPriceActive ? const Color(0xFFFFECE7) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isPriceActive ? AppTheme.primaryColor : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Harga',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isPriceActive ? FontWeight.bold : FontWeight.normal,
                              color: isPriceActive ? AppTheme.primaryColor : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _currentSort == 'price_asc'
                                ? Icons.arrow_upward
                                : (_currentSort == 'price_desc' ? Icons.arrow_downward : Icons.swap_vert),
                            size: 14,
                            color: isPriceActive ? AppTheme.primaryColor : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Konten Hasil Produk
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _fetchProducts(reset: true),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba gunakan kata kunci lain atau periksa filter.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                );
              },
              childCount: _products.length,
            ),
          ),
        ),

        // Indikator loading data lanjutan
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSortButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFECE7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.primaryColor : Colors.black87,
          ),
        ),
      ),
    );
  }
}

