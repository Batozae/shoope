import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';

// Layar Detail Produk Shoope
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final PageController _pageController = PageController();

  ProductDetail? _product;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentImageIndex = 0;
  bool _isFavorite = false; // State lokal toggle hati

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _productService.getProductDetail(widget.productId);
      if (mounted) {
        setState(() {
          _product = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat detail produk.';
          _isLoading = false;
        });
      }
    }
  }

  // Tampilkan Bottom Sheet untuk memilih kuantitas
  void _showQuantityBottomSheet({required bool isBuyNow}) {
    if (_product == null) return;
    final product = _product!;
    final maxStock = product.stock;

    if (maxStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok produk habis.')),
      );
      return;
    }

    int selectedQty = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.space16)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppDimens.space16,
                  right: AppDimens.space16,
                  top: AppDimens.space16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header produk di modal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: AppDimens.iconLg),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatRupiah(product.price),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: AppDimens.fontHeader,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppDimens.space4),
                              Text(
                                'Stok: $maxStock',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: AppDimens.fontBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: AppDimens.iconLg),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: AppDimens.space24),

                    // Baris Stepper Jumlah
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: AppDimens.fontTitle,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            // Tombol Minus
                            InkWell(
                              onTap: selectedQty > 1
                                  ? () {
                                      setModalState(() {
                                        selectedQty--;
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  border: Border.all(color: Colors.grey[300]!),
                                  color: selectedQty > 1 ? Colors.white : Colors.grey[100],
                                ),
                                child: const Icon(Icons.remove, size: AppDimens.iconSm),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                selectedQty.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimens.fontTitle),
                              ),
                            ),
                            // Tombol Plus
                            InkWell(
                              onTap: selectedQty < maxStock
                                  ? () {
                                      setModalState(() {
                                        selectedQty++;
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  border: Border.all(color: Colors.grey[300]!),
                                  color: selectedQty < maxStock ? Colors.white : Colors.grey[100],
                                ),
                                child: const Icon(Icons.add, size: AppDimens.iconSm),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space24),

                    // Tombol Konfirmasi
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBuyNow ? const Color(0xFFD0011B) : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _submitCartAction(selectedQty, isBuyNow: isBuyNow);
                        },
                        child: Text(
                          isBuyNow ? 'Beli Sekarang' : 'Konfirmasi',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimens.fontTitle),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Eksekusi penambahan ke keranjang dan tangkap error
  Future<void> _submitCartAction(int quantity, {required bool isBuyNow}) async {
    try {
      await context.read<CartProvider>().addToCart(widget.productId, quantity);

      if (!mounted) return;

      if (isBuyNow) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CheckoutScreen(productIds: [widget.productId]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil ditambahkan ke keranjang'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red[700],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menambahkan ke keranjang.'),
          backgroundColor: Colors.red[700],
        ),
      );
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'Produk tidak ditemukan.'),
              const SizedBox(height: AppDimens.space12),
              ElevatedButton(
                onPressed: _loadProductDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageList = product.images.isNotEmpty ? product.images : [product.imageUrl];
    final isOutOfStock = product.stock <= 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Konten Scrollable
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Galeri Gambar Persegi
                SizedBox(
                  width: screenWidth,
                  height: screenWidth,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageList.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageList[index],
                            fit: BoxFit.cover,
                            width: screenWidth,
                            height: screenWidth,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      // Indikator "1/4" di pojok kanan bawah
                      Positioned(
                        bottom: AppDimens.space12,
                        right: AppDimens.space12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppDimens.space12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${imageList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppDimens.fontCaption,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Bagian Harga, Diskon, Terjual & Favorite
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formatRupiah(product.price),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: AppDimens.fontPriceLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (product.originalPrice != null &&
                              product.originalPrice! > product.price) ...[
                            const SizedBox(width: AppDimens.space8),
                            Text(
                              formatRupiah(product.originalPrice!),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: AppDimens.fontBody,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1C5),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: const TextStyle(
                                  color: Color(0xFFEE4D2D),
                                  fontSize: AppDimens.fontCaption,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${formatSold(product.soldCount)} Terjual',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: AppDimens.fontCaption,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? AppTheme.primaryColor : Colors.grey[600],
                              size: AppDimens.iconLg,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.space8),

                      // 3. Judul produk dengan badge Mall jika isMall
                      RichText(
                        text: TextSpan(
                          children: [
                            if (product.isMall) ...[
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD0011B),
                                    borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                                  ),
                                  child: const Text(
                                    'Mall',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            TextSpan(
                              text: product.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: AppDimens.fontTitle,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.space8),

                // 4. Baris info statis jaminan
                InkWell(
                  onTap: _showComingSoon,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: AppDimens.space12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: AppDimens.iconSm,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppDimens.space8),
                        Expanded(
                          child: Text(
                            '15 Hari Pengembalian • 100% Original • COD',
                            style: TextStyle(
                              fontSize: AppDimens.fontCaption,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: AppDimens.iconMd,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.space8),

                // 5. Baris Rating Penilaian Produk
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: AppDimens.space12),
                  child: Row(
                    children: [
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: AppDimens.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space4),
                      const Icon(Icons.star, size: AppDimens.iconSm, color: Color(0xFFFFB800)),
                      const SizedBox(width: AppDimens.space8),
                      Text(
                        'Penilaian Produk (${formatCount(product.ratingCount)})',
                        style: TextStyle(
                          fontSize: AppDimens.fontBody,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        size: AppDimens.iconMd,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.space8),

                // 6. Kartu Toko
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.scaffoldBackgroundColor,
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppTheme.primaryColor,
                          size: AppDimens.iconMenu,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (product.isMall) ...[
                                  Container(
                                    margin: const EdgeInsets.only(right: AppDimens.space4),
                                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.space4, vertical: 1),
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
                                    product.shopName ?? 'Toko Resmi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppDimens.fontTitle,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimens.space4),
                            if (product.shopCity != null && product.shopCity!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: AppDimens.iconSm,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    product.shopCity!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: AppDimens.fontCaption,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.space8),

                // 7. Bagian Deskripsi Produk
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppDimens.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: AppDimens.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimens.space8),
                      Text(
                        product.description != null && product.description!.isNotEmpty
                            ? product.description!
                            : 'Tidak ada deskripsi produk.',
                        style: const TextStyle(
                          fontSize: AppDimens.fontBody,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90), // Beri ruang untuk bottom bar
              ],
            ),
          ),

          // Tombol Melayang Atas (Back & Cart)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppDimens.space8,
            left: AppDimens.pagePadding,
            right: AppDimens.pagePadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Back bulat
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: AppDimens.iconMd),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Tombol Cart bulat dengan badge
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: AppDimens.iconMd,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CartScreen()),
                              );
                            },
                          ),
                        ),
                        if (cartProvider.cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: AppDimens.iconSm,
                                minHeight: AppDimens.iconSm,
                              ),
                              child: Center(
                                child: Text(
                                  cartProvider.cartCount > 99
                                      ? '99+'
                                      : cartProvider.cartCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),

      // Bottom Bar Tetap
      bottomNavigationBar: Container(
        height: 56,
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
        child: Row(
          children: [
            // Chat Sekarang
            InkWell(
              onTap: _showComingSoon,
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_outlined, size: AppDimens.iconMd, color: Color(0xFF00BFA5)),
                    SizedBox(height: 2),
                    Text(
                      'Chat Sekarang',
                      style: TextStyle(fontSize: 9, color: Colors.black87),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 32, color: Colors.grey[200]),

            // Masukkan Keranjang
            Expanded(
              child: InkWell(
                onTap: isOutOfStock ? null : () => _showQuantityBottomSheet(isBuyNow: false),
                child: Container(
                  color: isOutOfStock ? Colors.grey[300] : const Color(0xFFFFECE7),
                  alignment: Alignment.center,
                  child: Text(
                    isOutOfStock ? 'Stok Habis' : 'Masukkan Keranjang',
                    style: TextStyle(
                      color: isOutOfStock ? Colors.grey[600] : AppTheme.primaryColor,
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Beli Sekarang
            Expanded(
              child: InkWell(
                onTap: isOutOfStock ? null : () => _showQuantityBottomSheet(isBuyNow: true),
                child: Container(
                  color: isOutOfStock ? Colors.grey[400] : const Color(0xFFD0011B),
                  alignment: Alignment.center,
                  child: Text(
                    isOutOfStock ? 'Stok Habis' : 'Beli Sekarang',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

