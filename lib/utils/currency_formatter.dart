// lib/utils/currency_formatter.dart
import 'package:intl/intl.dart';

final _formatter = NumberFormat('#,###', 'id_ID');

/// Mengubah angka menjadi format Rupiah, contoh: 15000000 → "Rp 15.000.000"
String formatRupiah(double amount) {
  return 'Rp ${_formatter.format(amount.toInt())}';
}