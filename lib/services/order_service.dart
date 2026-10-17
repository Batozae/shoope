import '../models/order.dart';
import 'api_client.dart';

// Hasil pembuatan pesanan baru
class CreateOrderResult {
  final int id;
  final double totalPrice;
  final String paymentMethod;
  final String status;

  CreateOrderResult({
    required this.id,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
  });

  factory CreateOrderResult.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return CreateOrderResult(
      id: parseInt(json['id']),
      totalPrice: parseDouble(json['total_price']),
      paymentMethod: json['payment_method'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }
}

// Layanan API untuk pesanan
class OrderService {
  final ApiClient _apiClient = ApiClient();

  // Buat pesanan baru
  Future<CreateOrderResult> createOrder({
    required int addressId,
    required String paymentMethod,
    List<int>? productIds,
  }) async {
    final body = <String, dynamic>{
      'address_id': addressId,
      'payment_method': paymentMethod,
    };

    if (productIds != null && productIds.isNotEmpty) {
      body['product_ids'] = productIds;
    }

    final data = await _apiClient.post(
      '/orders',
      body: body,
      withAuth: true,
    ) as Map<String, dynamic>;

    return CreateOrderResult.fromJson(data);
  }

  // Ambil daftar pesanan (opsional filter status)
  Future<List<OrderListItem>> getOrders({String? status}) async {
    final endpoint = (status != null && status.isNotEmpty)
        ? '/orders?status=$status'
        : '/orders';

    final data = await _apiClient.get(endpoint, withAuth: true);
    if (data is List) {
      return data
          .map((item) => OrderListItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Ambil rincian detail pesanan berdasarkan ID
  Future<OrderDetail> getOrderDetail(int id) async {
    final data = await _apiClient.get('/orders/$id', withAuth: true)
        as Map<String, dynamic>;
    return OrderDetail.fromJson(data);
  }

  // Simulasi pembayaran pesanan (pending -> paid)
  Future<void> payOrder(int id) async {
    await _apiClient.put('/orders/$id/pay', withAuth: true);
  }

  // Batalkan pesanan (pending -> cancelled, kembalikan stok)
  Future<void> cancelOrder(int id) async {
    await _apiClient.put('/orders/$id/cancel', withAuth: true);
  }

  // Majukan status pesanan (paid -> shipped, shipped -> completed)
  Future<void> advanceOrder(int id) async {
    await _apiClient.put('/orders/$id/advance', withAuth: true);
  }

  // Ambil ringkasan jumlah pesanan per status milik pengguna
  Future<OrderSummary> getOrderSummary() async {
    final data = await _apiClient.get('/orders/summary', withAuth: true)
        as Map<String, dynamic>;
    return OrderSummary.fromJson(data);
  }
}
