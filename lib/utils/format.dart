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

