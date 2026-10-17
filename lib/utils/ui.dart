import 'package:flutter/material.dart';

// Menampilkan SnackBar "Segera hadir" untuk fitur/elemen statis
void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Segera hadir'),
      duration: Duration(seconds: 1),
    ),
  );
}

