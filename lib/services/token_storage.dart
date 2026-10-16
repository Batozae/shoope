import 'package:shared_preferences/shared_preferences.dart';

// Layanan penyimpanan token autentikasi di SharedPreferences
class TokenStorage {
  static const String _keyToken = 'auth_token';

  // Simpan token ke storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // Baca token dari storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Hapus token dari storage
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}

