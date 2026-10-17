import '../models/app_notification.dart';
import 'api_client.dart';

// Layanan API untuk mengelola notifikasi pengguna
class NotificationService {
  final ApiClient _apiClient = ApiClient();

  // Ambil daftar notifikasi (opsional filter kategori: promo, pesanan, info)
  Future<List<AppNotification>> getNotifications({String? category}) async {
    final endpoint = (category != null && category.isNotEmpty)
        ? '/notifications?category=$category'
        : '/notifications';

    final data = await _apiClient.get(endpoint, withAuth: true);
    if (data is Map<String, dynamic>) {
      final rawItems = data['items'] as List? ?? [];
      return rawItems
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Ambil jumlah notifikasi belum dibaca
  Future<int> getUnreadCount() async {
    final data = await _apiClient.get('/notifications/unread-count', withAuth: true);
    if (data is Map<String, dynamic>) {
      final count = data['unread_count'];
      if (count is int) return count;
      if (count is num) return count.toInt();
      if (count is String) return int.tryParse(count) ?? 0;
    }
    return 0;
  }

  // Tandai seluruh notifikasi milik pengguna sebagai sudah dibaca
  Future<void> markAllRead() async {
    await _apiClient.put('/notifications/read-all', withAuth: true);
  }

  // Tandai satu notifikasi tertentu sebagai sudah dibaca
  Future<void> markRead(int id) async {
    await _apiClient.put('/notifications/$id/read', withAuth: true);
  }
}

