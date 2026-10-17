import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../services/api_client.dart';
import '../../services/order_service.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../address/address_form_screen.dart';
import '../address/address_list_screen.dart';
import '../order/order_list_screen.dart';

// Layar Checkout Pemesanan Produk
class CheckoutScreen extends StatefulWidget {
  final List<int> productIds;

  const CheckoutScreen({
    super.key,
    required this.productIds,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();

  Address? _selectedAddress;
  bool _isLoadingInitial = true;
  bool _isSubmitting = false;

  // Pilihan metode pembayaran tepat: COD, Transfer Bank, E-Wallet
  String _selectedPaymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Muat keranjang dan alamat secara bersamaan
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitial = true;
    });

    try {
      await context.read<CartProvider>().fetchCart();
      await _loadAddresses();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  // Muat alamat dan pilih alamat default otomatis
  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressService.getAddresses();
      if (!mounted) return;

      if (addresses.isNotEmpty) {
        // Cari alamat utama (isDefault), jika tidak ada pilih alamat pertama
        final defaultAddr = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        setState(() {
          _selectedAddress = defaultAddr;
        });
      } else {
        setState(() {
          _selectedAddress = null;
        });
      }
    } catch (_) {
      // Abaikan error saat memuat alamat awal
    }
  }

  // Filter toko dan produk yang sesuai dengan widget.productIds
  List<CartShop> _getFilteredShops(List<CartShop> allShops) {
    final filtered = <CartShop>[];
    for (final shop in allShops) {
      final matchedItems = shop.items
          .where((item) => widget.productIds.contains(item.productId))
          .toList();

      if (matchedItems.isNotEmpty) {
        filtered.add(
          CartShop(
            shopId: shop.shopId,
            shopName: shop.shopName,
            isMall: shop.isMall,
            items: matchedItems,
          ),
        );
      }
    }
    return filtered;
  }

  // Hitung total harga item yang dipilih
  double _calculateTotal(List<CartShop> shops) {
    double total = 0.0;
    for (final shop in shops) {
      for (final item in shop.items) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  // Hitung total kuantitas produk
  int _calculateTotalQuantity(List<CartShop> shops) {
    int total = 0;
    for (final shop in shops) {
      for (final item in shop.items) {
        total += item.quantity;
      }
    }
    return total;
  }

  // Submit pesanan ke server
  Future<void> _submitOrder(double totalPrice) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih alamat pengiriman terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _orderService.createOrder(
        addressId: _selectedAddress!.id,
        paymentMethod: _selectedPaymentMethod,
        productIds: widget.productIds,
      );

      // Sinkronisasi data keranjang belanja
      if (mounted) {
        await context.read<CartProvider>().fetchCart();
      }

      if (!mounted) return;
      _showSuccessDialog(result.id, totalPrice);
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
          content: const Text('Gagal membuat pesanan. Coba lagi.'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Tampilkan layar/dialog sukses setelah pesanan berhasil dibuat
  void _showSuccessDialog(int orderId, double totalPrice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.space24, vertical: 28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 68,
            ),
            const SizedBox(height: AppDimens.space16),
            const Text(
              'Pesanan Berhasil Dibuat',
              style: TextStyle(
                fontSize: AppDimens.fontHeader,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'Nomor Pesanan: #$orderId',
              style: TextStyle(fontSize: AppDimens.fontBody, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              formatRupiah(totalPrice),
              style: const TextStyle(
                fontSize: AppDimens.fontHeader,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const OrderListScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimens.fontTitle),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: AppDimens.fontTitle)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final filteredShops = _getFilteredShops(cartProvider.shops);
    final totalPayment = _calculateTotal(filteredShops);
    final totalQty = _calculateTotalQuantity(filteredShops);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoadingInitial
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppDimens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Kartu Alamat Pengiriman
                  _buildAddressSection(),
                  const SizedBox(height: AppDimens.space8),

                  // 2. Daftar Produk per Toko
                  ...filteredShops.map((shop) => _buildShopProductsCard(shop)),

                  const SizedBox(height: AppDimens.space8),

                  // 3. Pilihan Metode Pembayaran
                  _buildPaymentMethodSection(),

                  const SizedBox(height: AppDimens.space8),

                  // 4. Rincian Pembayaran
                  _buildPaymentSummarySection(totalQty, totalPayment),
                ],
              ),
            ),
      bottomNavigationBar: _isLoadingInitial
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: 10),
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
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontSize: AppDimens.fontCaption, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRupiah(totalPayment),
                          style: const TextStyle(
                            fontSize: AppDimens.fontPrice,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_selectedAddress == null || filteredShops.isEmpty)
                              ? Colors.grey[400]
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          ),
                        ),
                        onPressed: (_isSubmitting || _selectedAddress == null || filteredShops.isEmpty)
                            ? null
                            : () => _submitOrder(totalPayment),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontSize: AppDimens.fontTitle,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Bagian Alamat Pengiriman
  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: InkWell(
        onTap: () async {
          if (_selectedAddress != null) {
            final selected = await Navigator.of(context).push<Address>(
              MaterialPageRoute(
                builder: (_) => const AddressListScreen(selectMode: true),
              ),
            );
            if (selected != null) {
              setState(() {
                _selectedAddress = selected;
              });
            }
          } else {
            final added = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddressFormScreen()),
            );
            if (added == true) {
              _loadAddresses();
            }
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppTheme.primaryColor,
              size: AppDimens.iconLg,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _selectedAddress != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Alamat Pengiriman',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimens.fontBody,
                              ),
                            ),
                            if (_selectedAddress!.isDefault) ...[
                              const SizedBox(width: AppDimens.space8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECE7),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                                ),
                                child: const Text(
                                  'Utama',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_selectedAddress!.recipientName} (${_selectedAddress!.phone})',
                          style: const TextStyle(
                            fontSize: AppDimens.fontBody,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedAddress!.fullAddress}, ${_selectedAddress!.city}, ${_selectedAddress!.postalCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Belum Ada Alamat Pengiriman',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimens.fontTitle,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ketuk di sini untuk menambahkan alamat baru',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right, size: AppDimens.iconMd, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Kartu Produk per Toko
  Widget _buildShopProductsCard(CartShop shop) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: AppDimens.space8),
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toko
          Row(
            children: [
              if (shop.isMall) ...[
                Container(
                  margin: const EdgeInsets.only(right: 6),
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
              Text(
                shop.shopName ?? 'Toko Shoope',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimens.fontBody,
                ),
              ),
            ],
          ),
          const Divider(height: AppDimens.space16),

          // Daftar Item
          ...shop.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    child: Image.network(
                      item.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: AppDimens.iconLg),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatRupiah(item.price),
                              style: const TextStyle(
                                fontSize: AppDimens.fontBody,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
          }),
        ],
      ),
    );
  }

  // Bagian Pilihan Metode Pembayaran
  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: AppDimens.fontBody, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
            title: const Text('COD (Bayar di Tempat)', style: TextStyle(fontSize: AppDimens.fontBody)),
            value: 'COD',
            groupValue: _selectedPaymentMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              }
            },
          ),
          RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
            title: const Text('Transfer Bank', style: TextStyle(fontSize: AppDimens.fontBody)),
            value: 'Transfer Bank',
            groupValue: _selectedPaymentMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              }
            },
          ),
          RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
            title: const Text('E-Wallet', style: TextStyle(fontSize: AppDimens.fontBody)),
            value: 'E-Wallet',
            groupValue: _selectedPaymentMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Bagian Rincian Pembayaran
  Widget _buildPaymentSummarySection(int totalQty, double totalPayment) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(fontSize: AppDimens.fontBody, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Produk ($totalQty barang)',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                formatRupiah(totalPayment),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: const TextStyle(fontSize: AppDimens.fontBody, fontWeight: FontWeight.bold),
              ),
              Text(
                formatRupiah(totalPayment),
                style: const TextStyle(
                  fontSize: AppDimens.fontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

