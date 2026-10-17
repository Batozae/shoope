// Model representasi data pesanan pada daftar pesanan
class OrderListItem {
  final int id;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final String createdAt;
  final int itemCount;
  final String? firstProductName;
  final String? firstProductImage;

  OrderListItem({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.itemCount,
    this.firstProductName,
    this.firstProductImage,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      id: _parseInt(json['id']),
      totalPrice: _parseDouble(json['total_price']),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      itemCount: _parseInt(json['item_count'], 1),
      firstProductName: json['first_product_name'] as String?,
      firstProductImage: json['first_product_image'] as String?,
    );
  }
}

// Model item produk di dalam pesanan
class OrderItem {
  final int productId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double priceAtPurchase;
  final double subtotal;

  OrderItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.priceAtPurchase,
    required this.subtotal,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final qty = _parseInt(json['quantity'], 1);
    final price = _parseDouble(json['price_at_purchase']);
    final sub = json['subtotal'] != null
        ? _parseDouble(json['subtotal'])
        : (price * qty);

    return OrderItem(
      productId: _parseInt(json['product_id']),
      productName: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      quantity: qty,
      priceAtPurchase: price,
      subtotal: sub,
    );
  }
}

// Model alamat pengiriman di dalam detail pesanan
class OrderAddress {
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String city;
  final String postalCode;

  OrderAddress({
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.postalCode,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullAddress: json['full_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
    );
  }
}

// Model representasi data detail lengkap pesanan
class OrderDetail {
  final int id;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final String createdAt;
  final OrderAddress address;
  final List<OrderItem> items;

  OrderDetail({
    required this.id,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.items,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final addrJson = json['address'] as Map<String, dynamic>? ?? {};
    final itemsList = (json['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderDetail(
      id: _parseInt(json['id']),
      totalPrice: _parseDouble(json['total_price']),
      paymentMethod: json['payment_method'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String? ?? '',
      address: OrderAddress.fromJson(addrJson),
      items: itemsList,
    );
  }
}

// Model ringkasan jumlah pesanan per status milik pengguna
class OrderSummary {
  final int pending;
  final int paid;
  final int shipped;
  final int completed;

  const OrderSummary({
    this.pending = 0,
    this.paid = 0,
    this.shipped = 0,
    this.completed = 0,
  });

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      pending: _parseInt(json['pending']),
      paid: _parseInt(json['paid']),
      shipped: _parseInt(json['shipped']),
      completed: _parseInt(json['completed']),
    );
  }
}

