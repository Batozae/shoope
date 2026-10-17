import '../models/address.dart';
import 'api_client.dart';

// Layanan API untuk mengelola alamat pengiriman
class AddressService {
  final ApiClient _apiClient = ApiClient();

  // Ambil semua alamat milik user
  Future<List<Address>> getAddresses() async {
    final data = await _apiClient.get('/addresses', withAuth: true);
    if (data is List) {
      return data
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Tambah alamat pengiriman baru
  Future<Address> createAddress({
    required String recipientName,
    required String phone,
    required String fullAddress,
    required String city,
    required String postalCode,
    bool isDefault = false,
  }) async {
    final data = await _apiClient.post(
      '/addresses',
      body: {
        'recipient_name': recipientName,
        'phone': phone,
        'full_address': fullAddress,
        'city': city,
        'postal_code': postalCode,
        'is_default': isDefault,
      },
      withAuth: true,
    ) as Map<String, dynamic>;

    return Address.fromJson(data);
  }

  // Hapus alamat berdasarkan ID
  Future<void> deleteAddress(int id) async {
    await _apiClient.delete('/addresses/$id', withAuth: true);
  }
}

