import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Helper format angka ke mata uang Rupiah (contoh: Rp38.400)
String formatRupiah(num number) {
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatCurrency.format(number);
}

// Helper format jumlah terjual (contoh: 123 -> "123", 10500 -> "10RB+", 1500000 -> "1JT+")
String formatSold(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 1000000) {
    final rb = count ~/ 1000;
    return '${rb}RB+';
  } else {
    final jt = count ~/ 1000000;
    return '${jt}JT+';
  }
}

// Helper format jumlah hitungan misal rating count (contoh: 261400 -> "261,4RB")
String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 1000000) {
    final rb = count / 1000.0;
    final formatted = rb.toStringAsFixed(1).replaceAll('.', ',');
    // Hapus trailing ,0 jika genap
    final clean = formatted.endsWith(',0') ? formatted.substring(0, formatted.length - 2) : formatted;
    return '${clean}RB';
  } else {
    final jt = count / 1000000.0;
    final formatted = jt.toStringAsFixed(1).replaceAll('.', ',');
    final clean = formatted.endsWith(',0') ? formatted.substring(0, formatted.length - 2) : formatted;
    return '${clean}JT';
  }
}

// Helper label status pesanan dalam bahasa Indonesia
String statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Belum Bayar';
    case 'paid':
      return 'Dikemas';
    case 'shipped':
      return 'Dikirim';
    case 'completed':
      return 'Selesai';
    case 'cancelled':
      return 'Dibatalkan';
    default:
      return status;
  }
}

// Helper warna tema status pesanan
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const Color(0xFFEE4D2D); // Oranye Shopee
    case 'paid':
      return const Color(0xFF1E88E5); // Biru
    case 'shipped':
      return const Color(0xFF00897B); // Teal
    case 'completed':
      return const Color(0xFF2E7D32); // Hijau
    case 'cancelled':
      return const Color(0xFF757575); // Abu-abu
    default:
      return const Color(0xFF757575);
  }
}
