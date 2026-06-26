import 'package:intl/intl.dart';

String formatRupiah(double amount) {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id-ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return currencyFormatter.format(amount);
}
