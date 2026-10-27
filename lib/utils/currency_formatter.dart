import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Returns ₹2,16,949
  static String formatInr(double amount) {
    return _inrFormatter.format(amount);
  }

  /// Returns ₹2,16,949.00
  static String format(double amount) {
    return _inrWithDecimals.format(amount);
  }

  /// Splits ₹2,16,949.00 into main ['₹2,16,949', '.00']
  static (String main, String decimals) splitInrWithDecimals(double amount) {
    final full = _inrWithDecimals.format(amount);
    final dotIndex = full.lastIndexOf('.');
    if (dotIndex != -1) {
      return (full.substring(0, dotIndex), full.substring(dotIndex));
    }
    return (full, '.00');
  }
}
