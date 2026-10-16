// Model representasi data Produk
class Product {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final int discountPercent;
  final String imageUrl;
  final double rating;
  final int ratingCount;
  final int soldCount;
  final int stock;
  final int? shopId;
  final String? shopName;
  final String? shopCity;
  final bool isMall;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
    required this.soldCount,
    required this.stock,
    this.shopId,
    this.shopName,
    this.shopCity,
    required this.isMall,
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

  // Helper konversi aman ke boolean
  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) {
      return val.toLowerCase() == 'true' || val == '1';
    }
    return false;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: _parseDouble(json['price']),
      originalPrice: json['original_price'] != null ? _parseDouble(json['original_price']) : null,
      discountPercent: _parseInt(json['discount_percent']),
      imageUrl: json['image_url'] as String? ?? '',
      rating: _parseDouble(json['rating']),
      ratingCount: _parseInt(json['rating_count']),
      soldCount: _parseInt(json['sold_count']),
      stock: _parseInt(json['stock']),
      shopId: json['shop_id'] != null ? _parseInt(json['shop_id']) : null,
      shopName: json['shop_name'] as String?,
      shopCity: json['shop_city'] as String?,
      isMall: _parseBool(json['is_mall']),
    );
  }
}

// Model representasi Detail Produk (Product + description & images)
class ProductDetail extends Product {
  final String? description;
  final List<String> images;

  ProductDetail({
    required super.id,
    required super.name,
    required super.price,
    super.originalPrice,
    required super.discountPercent,
    required super.imageUrl,
    required super.rating,
    required super.ratingCount,
    required super.soldCount,
    required super.stock,
    super.shopId,
    super.shopName,
    super.shopCity,
    required super.isMall,
    this.description,
    required this.images,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final baseProduct = Product.fromJson(json);

    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => img.toString())
          .toList();
    } else if (baseProduct.imageUrl.isNotEmpty) {
      parsedImages = [baseProduct.imageUrl];
    }

    return ProductDetail(
      id: baseProduct.id,
      name: baseProduct.name,
      price: baseProduct.price,
      originalPrice: baseProduct.originalPrice,
      discountPercent: baseProduct.discountPercent,
      imageUrl: baseProduct.imageUrl,
      rating: baseProduct.rating,
      ratingCount: baseProduct.ratingCount,
      soldCount: baseProduct.soldCount,
      stock: baseProduct.stock,
      shopId: baseProduct.shopId,
      shopName: baseProduct.shopName,
      shopCity: baseProduct.shopCity,
      isMall: baseProduct.isMall,
      description: json['description'] as String?,
      images: parsedImages,
    );
  }
}

