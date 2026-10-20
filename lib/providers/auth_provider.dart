import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

// 	AuthProvider memakai ChangeNotifier: setiap state berubah memanggil notifyListeners(), 
//  sehingga layar yang mendengarkan otomatis dibangun ulang. Ini inti state management dengan provider.
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();
  //	Status login disimpan di memori: data user, token, dan penanda loading.
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  // 		isAuthenticated bernilai true hanya jika token dan data user sama-sama ada.
  bool get isAuthenticated => _token != null && _user != null;
  //	tryAutoLogin: alur login otomatis saat aplikasi dibuka.
  // Coba login otomatis menggunakan token yang tersimpan
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    //Ambil token dari penyimpanan lokal. Kalau kosong berarti user belum login.
    try {
      final savedToken = await _tokenStorage.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      //	Token diverifikasi ke server lewat GET /auth/me.
      //  Token ikut terkirim otomatis oleh ApiClient. Kalau valid, server mengembalikan data user.
      final data = await _apiClient.get('/auth/me');
      _user = User.fromJson(data as Map<String, dynamic>);
      _token = savedToken;
      _isLoading = false;
      //	Kalau gagal (token kedaluwarsa, tidak valid, atau server tidak terjangkau), token dihapus dan user diminta login ulang.
      notifyListeners();
      return true;
    } catch (_) {
      // Jika token tidak valid / gagal, hapus token tersimpan
      await _tokenStorage.deleteToken();
      _user = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return false;
    } 
  }

  // login: kirim email dan password ke /auth/login. withAuth false karena belum punya token.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        withAuth: false,
      ) as Map<String, dynamic>;
      //	Token dan data user disimpan di memori, 
      //  lalu token disimpan permanen di perangkat (baris 69) supaya sesi bertahan setelah aplikasi ditutup.
      _token = data['token'] as String;
      _user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(_token!);
      //	finally: apa pun hasilnya, status loading dimatikan agar tombol aktif lagi.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 	register hanya membuat akun dan tidak menyimpan token. Login otomatis dilakukan oleh layar register.
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        withAuth: false,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // logout: cukup hapus token dan data user di perangkat. Karena JWT bersifat stateless, tidak perlu memanggil server.
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    _user = null;
    _token = null;
    notifyListeners();
  }

  // Perbarui profil user (name, phone)
  Future<void> updateProfile({String? name, String? phone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final data = await _apiClient.put(
        '/auth/me',
        body: body,
        withAuth: true,
      ) as Map<String, dynamic>;

      _user = User.fromJson(data);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

