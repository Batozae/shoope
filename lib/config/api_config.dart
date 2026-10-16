// Konfigurasi endpoint dasar API
import 'package:flutter/foundation.dart' show kIsWeb;

const String baseUrl = kIsWeb
    ? 'http://localhost:3000/api'
    : 'http://10.0.2.2:3000/api';
