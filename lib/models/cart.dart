// Model representasi item dan toko di keranjang belanja
class CartItem {
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;
  int quantity;
  final double subtotal;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.quantity,
    required this.subtotal,
  });

  // Helper konversi angka aman ke double
  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? defaultVal;
    }
    return defaultVal;
  }

  // Helper konversi angka aman ke int
  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
    }
    return defaultVal;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: _parseInt(json['product_id']),
      name: json['name'] as String? ?? '',
      price: _parseDouble(json['price']),
      imageUrl: json['image_url'] as String? ?? '',
      stock: _parseInt(json['stock']),
      quantity: _parseInt(json['quantity'], 1),
      subtotal: _parseDouble(json['subtotal']),
    );
  }
}

class CartShop {
  final int? shopId;
  final String? shopName;
  final bool isMall;
  final List<CartItem> items;

  CartShop({
    this.shopId,
    this.shopName,
    required this.isMall,
    required this.items,
  });

  static int? _parseNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
  }

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) {
      return val.toLowerCase() == 'true' || val == '1';
    }
    return false;
  }

  factory CartShop.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return CartShop(
      shopId: _parseNullableInt(json['shop_id']),
      shopName: json['shop_name'] as String?,
      isMall: _parseBool(json['is_mall']),
      items: itemsList,
    );
  }
}

