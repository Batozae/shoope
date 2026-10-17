import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/api_client.dart';

// Provider state keranjang belanja
class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  int _cartCount = 0;
  List<CartShop> _shops = [];
  bool _isLoading = false;
  String? _error;
  final Set<int> _selectedIds = <int>{};

  int get cartCount => _cartCount;
  List<CartShop> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<int> get selectedIds => _selectedIds;

  // Daftar semua CartItem yang ada di keranjang
  List<CartItem> get allItems {
    final list = <CartItem>[];
    for (final shop in _shops) {
      list.addAll(shop.items);
    }
    return list;
  }

  // Jumlah item unik yang dipilih untuk checkout
  int get selectedCount => _selectedIds.length;

  // Total harga seluruh item yang dipilih
  double get selectedTotal {
    double total = 0.0;
    for (final item in allItems) {
      if (_selectedIds.contains(item.productId)) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  // Apakah semua item di keranjang terpilih
  bool get allSelected {
    final items = allItems;
    if (items.isEmpty) return false;
    return items.every((item) => _selectedIds.contains(item.productId));
  }

  // Muat ulang jumlah item keranjang dari API /cart
  Future<void> refreshCount() async {
    try {
      final data = await _apiClient.get('/cart', withAuth: true);
      if (data is Map<String, dynamic>) {
        final totalItems = data['total_items'];
        if (totalItems is int) {
          _cartCount = totalItems;
        } else if (totalItems != null) {
          _cartCount = int.tryParse(totalItems.toString()) ?? 0;
        } else {
          _cartCount = 0;
        }
        notifyListeners();
      }
    } catch (_) {
      // Abaikan error saat refresh jumlah keranjang (misal belum login / offline)
    }
  }

  // Ambil data lengkap keranjang belanja
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get('/cart', withAuth: true);
      if (data is Map<String, dynamic>) {
        final rawShops = data['shops'] as List? ?? [];
        _shops = rawShops
            .map((s) => CartShop.fromJson(s as Map<String, dynamic>))
            .toList();

        final totalItems = data['total_items'];
        if (totalItems is int) {
          _cartCount = totalItems;
        } else if (totalItems != null) {
          _cartCount = int.tryParse(totalItems.toString()) ?? 0;
        } else {
          _cartCount = 0;
        }

        // Hapus selectedIds yang sudah tidak ada di keranjang
        final currentProductIds = allItems.map((e) => e.productId).toSet();
        _selectedIds.removeWhere((id) => !currentProductIds.contains(id));
      } else {
        _shops = [];
        _cartCount = 0;
        _selectedIds.clear();
      }
    } catch (e) {
      _error = e is ApiException ? e.message : 'Gagal memuat keranjang.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah produk ke keranjang belanja
  Future<void> addToCart(int productId, int quantity) async {
    await _apiClient.post(
      '/cart',
      body: {
        'product_id': productId,
        'quantity': quantity,
      },
      withAuth: true,
    );
    await refreshCount();
  }

  // Toggle seleksi satu item
  void toggleItem(int productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
    }
    notifyListeners();
  }

  // Toggle seleksi seluruh item di satu toko
  void toggleShop(int? shopId) {
    final shop = _shops.firstWhere(
      (s) => s.shopId == shopId,
      orElse: () => CartShop(shopId: shopId, isMall: false, items: []),
    );
    if (shop.items.isEmpty) return;

    final allShopItemsSelected =
        shop.items.every((item) => _selectedIds.contains(item.productId));

    if (allShopItemsSelected) {
      for (final item in shop.items) {
        _selectedIds.remove(item.productId);
      }
    } else {
      for (final item in shop.items) {
        _selectedIds.add(item.productId);
      }
    }
    notifyListeners();
  }

  // Toggle seleksi semua item di keranjang
  void toggleAll() {
    if (allSelected) {
      _selectedIds.clear();
    } else {
      for (final item in allItems) {
        _selectedIds.add(item.productId);
      }
    }
    notifyListeners();
  }

  // Update kuantitas item di keranjang
  Future<void> updateQuantity(int productId, int quantity) async {
    // Cari item di state lokal untuk validasi batas 1..stok
    CartItem? targetItem;
    for (final shop in _shops) {
      for (final item in shop.items) {
        if (item.productId == productId) {
          targetItem = item;
          break;
        }
      }
      if (targetItem != null) break;
    }

    if (targetItem == null) return;

    final validQty = quantity.clamp(1, targetItem.stock);

    await _apiClient.put(
      '/cart/$productId',
      body: {'quantity': validQty},
      withAuth: true,
    );

    // Perbarui state lokal
    targetItem.quantity = validQty;

    // Hitung ulang total item
    int newTotalCount = 0;
    for (final item in allItems) {
      newTotalCount += item.quantity;
    }
    _cartCount = newTotalCount;

    notifyListeners();
  }

  // Hapus beberapa item dari keranjang
  Future<void> removeItems(List<int> ids) async {
    for (final id in ids) {
      try {
        await _apiClient.delete('/cart/$id', withAuth: true);
      } catch (_) {
        // Abaikan error individu dan lanjutkan
      }
    }
    await fetchCart();
  }
}
