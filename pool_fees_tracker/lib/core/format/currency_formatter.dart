import 'package:intl/intl.dart';

/// Formata valores monetários de forma consistente em toda a app
/// (duas casas decimais, símbolo da moeda escolhida nas definições).
class CurrencyFormatter {
  final NumberFormat _format;

  CurrencyFormatter(String currencyCode)
    : _format = NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: switch (currencyCode) {
          'EUR' => '€',
          'USD' => '\$',
          _ => '$currencyCode ',
        },
        decimalDigits: 2,
      );

  String format(double value) => _format.format(value);

  String formatCompact(double value) {
    if (value.abs() >= 1000000) {
      return '${_format.currencySymbol}${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value.abs() >= 10000) {
      return '${_format.currencySymbol}${(value / 1000).toStringAsFixed(1)}k';
    }
    return format(value);
  }
}

String formatRelativeUpdatedAt(DateTime updatedAt, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(updatedAt);
  if (diff.inSeconds < 5) return 'Updated just now';
  if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
  return 'Updated ${diff.inHours}h ago';
}
