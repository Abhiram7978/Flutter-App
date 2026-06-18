import 'package:intl/intl.dart';

/// Centralised formatting so price/volume/date display is consistent
/// across every screen.
class Formatters {
  const Formatters._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactVolume = NumberFormat.compact(
    locale: 'en_IN',
  );

  static final DateFormat _displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');

  static String price(double value) => _inr.format(value);

  static String changePct(double? value) {
    if (value == null) return '—';
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String volume(int value) => _compactVolume.format(value);

  static String date(DateTime value) => _displayDate.format(value);

  static String shortDate(DateTime value) => _shortDate.format(value);
}
