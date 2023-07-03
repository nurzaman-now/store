import 'package:intl/intl.dart';

formatMoney(var value) {
  String formattedTotal = NumberFormat.currency(
    symbol: 'Rp. ',
    decimalDigits: 0,
    locale: 'id_ID',
  ).format(value);
  return formattedTotal;
}
