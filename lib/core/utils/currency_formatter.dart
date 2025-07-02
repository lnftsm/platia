import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatTRY(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatUSD(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String format(double amount, String currency, {String? locale}) {
    switch (currency.toUpperCase()) {
      case 'TRY':
        return formatTRY(amount);
      case 'USD':
        return formatUSD(amount);
      default:
        final formatter = NumberFormat.currency(
          locale: locale ?? 'tr_TR',
          symbol: currency,
          decimalDigits: 2,
        );
        return formatter.format(amount);
    }
  }
}
