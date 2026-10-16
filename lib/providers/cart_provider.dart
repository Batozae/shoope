import 'package:flutter/material.dart';
import '../services/api_client.dart';

// Provider state keranjang belanja
class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  int _cartCount = 0;

  int get cartCount => _cartCount;

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
}

