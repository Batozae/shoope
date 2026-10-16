import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

// Provider manajemen state autentikasi pengguna
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  // Coba login otomatis menggunakan token yang tersimpan
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _tokenStorage.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verifikasi token ke endpoint /auth/me
      final data = await _apiClient.get('/auth/me');
      _user = User.fromJson(data as Map<String, dynamic>);
      _token = savedToken;
      _isLoading = false;
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

  // Login dengan email dan password
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

      _token = data['token'] as String;
      _user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(_token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registrasi user baru
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

  // Logout dan hapus token
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    _user = null;
    _token = null;
    notifyListeners();
  }
}

