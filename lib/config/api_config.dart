// Konfigurasi endpoint dasar API
import 'package:flutter/foundation.dart' show kIsWeb;
//	Alamat dasar API dipusatkan di satu tempat. Web memakai localhost, emulator Android memakai 10.0.2.2 (alias emulator untuk komputer host, 
//karena localhost di emulator menunjuk ke emulator itu sendiri). Untuk HP fisik, ganti ke IP laptop.
const String baseUrl = kIsWeb
    ? 'http://localhost:3000/api'
    : 'http://10.0.2.2:3000/api';
