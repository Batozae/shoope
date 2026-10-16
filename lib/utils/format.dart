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
