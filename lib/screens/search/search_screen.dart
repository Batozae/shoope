import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';


class SearchScreen extends StatefulWidget {
// Satu layar untuk dua kebutuhan: pencarian bebas (dari kotak cari) dan penelusuran kategori (dari Beranda), 
// dibedakan lewat parameter opsional categoryId dan title.
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
  String _currentSort = 'newest'; //	Nilai sort saat ini: newest, popular, price_asc, atau price_desc. Sama persis dengan kata kunci di whitelist server.

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? ''); //Isi awal kotak pencarian, lalu langsung memuat produk (baris 48).
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

  void _onScroll() { //	Infinite scroll, logikanya sama dengan Beranda.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore && !_isLoading && _currentPage < _totalPages) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _fetchProducts({bool reset = false}) async { //	_fetchProducts: ambil halaman 1. Parameter yang dikirim: teks pencarian (baris 78), kategori (baris 81), dan sort (baris 82). reset true mengosongkan daftar lama.
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
    } catch (e) { //	Kalau gagal, pesan dari ApiException ditampilkan. Selain itu pakai pesan umum.
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException
              ? e.message
              : 'Gagal memuat produk.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async { //	_loadMoreProducts: ambil halaman berikutnya dengan filter yang sama dan tambahkan ke daftar.
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
  void _changeSort(String sortKey) { //Ganti urutan: ubah nilai sort lalu muat ulang dari halaman 1. Kalau sort yang sama diketuk lagi, tidak terjadi apa-apa.
    if (_currentSort == sortKey) return;
    setState(() {
      _currentSort = sortKey;
    });
    _fetchProducts(reset: true);
  }

  // Toggle sort harga antara price_asc dan price_desc
  void _togglePriceSort() { //		Tombol Harga bergantian antara termurah (price_asc) dan termahal (price_desc).
    if (_currentSort == 'price_asc') {
      _changeSort('price_desc');
    } else {
      _changeSort('price_asc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPriceActive =
        _currentSort == 'price_asc' || _currentSort == 'price_desc';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: AppDimens.pagePadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: TextField(
            controller: _searchController,
            autofocus:
                widget.categoryId == null &&
                (widget.initialQuery == null || widget.initialQuery!.isEmpty),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _fetchProducts(reset: true), 	//Pencarian dijalankan saat user menekan enter di keyboard.
            style: const TextStyle(fontSize: AppDimens.fontTitle),
            decoration: InputDecoration(
              hintText: widget.title != null
                  ? 'Cari di ${widget.title}...'
                  : 'Cari di Shoope...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: AppDimens.fontBody,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: AppDimens.iconMd,
                color: Colors.grey,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: AppDimens.iconSm,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _fetchProducts(reset: true);
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
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
          Container( //Baris tombol urutan: Terbaru, Terlaris, dan Harga (dengan ikon panah naik atau turun).
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.pagePadding,
              vertical: AppDimens.space8,
            ),
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
                const SizedBox(width: AppDimens.space8),

                // Terlaris
                Expanded(
                  child: _buildSortButton(
                    label: 'Terlaris',
                    isActive: _currentSort == 'popular',
                    onTap: () => _changeSort('popular'),
                  ),
                ),
                const SizedBox(width: AppDimens.space8),

                // Harga (dengan ikon panah naik/turun)
                Expanded(
                  child: InkWell(
                    onTap: _togglePriceSort,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isPriceActive
                            ? const Color(0xFFFFECE7)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        border: Border.all(
                          color: isPriceActive
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Harga',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isPriceActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPriceActive
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _currentSort == 'price_asc'
                                ? Icons.arrow_upward
                                : (_currentSort == 'price_desc'
                                      ? Icons.arrow_downward
                                      : Icons.swap_vert),
                            size: AppDimens.iconSm,
                            color: isPriceActive
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() { //	_buildBody menangani empat kondisi: loading (baris 315), error dengan Coba Lagi (baris 321), hasil kosong Produk tidak ditemukan (baris 344), dan grid hasil (baris 369).
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppDimens.space12),
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
            Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimens.space4),
            Text(
              'Coba gunakan kata kunci lain atau periksa filter.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppDimens.space8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              mainAxisSpacing: AppDimens.space8,
              crossAxisSpacing: AppDimens.space8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) { //		Grid hasil memakai ProductCard yang sama dengan Beranda, jadi tampilannya konsisten dan tidak ada kode ganda.
              final product = _products[index];
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
            }, childCount: _products.length),
          ),
        ),

        // Indikator loading data lanjutan
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
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

  Widget _buildSortButton({ //	Helper tombol urutan: tampilan aktif atau tidak aktif ditentukan oleh isActive.
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFECE7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
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
