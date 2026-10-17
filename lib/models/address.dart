// Model representasi data alamat pengiriman
class Address {
  final int id;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String city;
  final String postalCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.postalCode,
    required this.isDefault,
  });

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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _parseInt(json['id']),
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullAddress: json['full_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      isDefault: _parseBool(json['is_default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_name': recipientName,
      'phone': phone,
      'full_address': fullAddress,
      'city': city,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}

