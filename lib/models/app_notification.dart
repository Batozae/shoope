// Model representasi data notifikasi aplikasi
class AppNotification {
  final int id;
  final String category;
  final String title;
  final String body;
  final String? imageUrl;
  bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultVal;
    return defaultVal;
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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _parseInt(json['id']),
      category: json['category'] as String? ?? 'info',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isRead: _parseBool(json['is_read']),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

