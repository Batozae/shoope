import 'package:shared_preferences/shared_preferences.dart';

// Layanan penyimpanan token autentikasi di SharedPreferences
class TokenStorage {
  //	Nama kunci tempat token disimpan di SharedPreferences (penyimpanan key-value lokal di perangkat).
  static const String _keyToken = 'auth_token';

  // Simpan token ke storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  	//getToken: dibaca saat auto-login dan setiap kali membuat request yang butuh otorisasi.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  		//deleteToken: dipakai saat logout atau saat token terbukti tidak valid.
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}

