import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_storage.dart';

// 	ApiException: error kustom yang membawa pesan dan status code. 
// Pesannya berasal dari server, jadi bisa langsung ditampilkan ke user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

// Klien HTTP untuk komunikasi dengan backend API
class ApiClient {
  //Batas waktu 10 detik per request, supaya aplikasi tidak menggantung kalau server mati.
  final TokenStorage _tokenStorage = TokenStorage();
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // 	Menyusun header request: format JSON, dan kalau withAuth true ditambahkan Authorization: 
  // Bearer token dari penyimpanan. Request publik (login, daftar produk) memakai withAuth false.
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  } //Semua response melewati sini. Server selalu membalas format success, message, 
  // data. Kalau success false atau status 400 ke atas, dilempar ApiException berisi pesan server.

  // Parse response JSON dan verifikasi status serta flag success
  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      // Jika body bukan JSON valid
      if (response.statusCode >= 400) {
        throw ApiException('Terjadi kesalahan pada server.', response.statusCode);
      }
      return null;
    }

    if (body is Map<String, dynamic>) {
      final bool success = body['success'] == true;
      final String message = body['message'] ?? 'Terjadi kesalahan.';

      if (!success || response.statusCode >= 400) {
        //Kalau sukses, yang dikembalikan hanya isi data, jadi pemanggil tidak perlu membuka pembungkus response lagi.
        throw ApiException(message, response.statusCode);
      }

      return body['data'];
    }

    if (response.statusCode >= 400) {
      throw ApiException('Terjadi kesalahan pada server.', response.statusCode);
    }
    //	Pembungkus request: error jaringan, timeout,
    // dan koneksi gagal disamakan menjadi satu pesan, yaitu Tidak dapat terhubung ke server.
    return body;
  }

  // Wrapper untuk menangkap error jaringan dan timeout
  Future<http.Response> _safeRequest(Future<http.Response> Function() requestFn) async {
    try {
      return await requestFn().timeout(_timeoutDuration);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } on TimeoutException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } on http.ClientException {
      throw ApiException('Tidak dapat terhubung ke server.');
    } catch (e) {
      //		Metode get, post, put, delete punya pola sama: 
      //    susun URL dari baseUrl + endpoint, kirim lewat _safeRequest, proses hasilnya di _handleResponse.
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server.');
    }
  }

  // Request GET
  Future<dynamic> get(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _safeRequest(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      return await http.get(uri, headers: headers);
    });
    return _handleResponse(response);
  }

  // Request POST
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _safeRequest(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      return await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
    return _handleResponse(response);
  }

  // Request PUT
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _safeRequest(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      return await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
    return _handleResponse(response);
  }

  // Request DELETE
  Future<dynamic> delete(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _safeRequest(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      return await http.delete(uri, headers: headers);
    });
    return _handleResponse(response);
  }
}

