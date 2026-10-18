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

/// Formata um preço de token (ex.: USDC por ETH, ver `priceAtTick`) com
/// casas decimais adaptadas à magnitude — um par de stablecoins perto de
/// 1.0 precisa de mais precisão que um preço de milhares.
String formatTokenPrice(double value) {
  final abs = value.abs();
  if (abs == 0) return '0';
  if (abs >= 1000) {
    return NumberFormat('#,##0', 'en_US').format(value);
  }
  if (abs >= 1) {
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }
  if (abs >= 0.0001) {
    return value.toStringAsFixed(4);
  }
  return value.toStringAsExponential(2);
}

String formatRelativeUpdatedAt(DateTime updatedAt, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(updatedAt);
  if (diff.inSeconds < 5) return 'Atualizado agora mesmo';
  if (diff.inSeconds < 60) return 'Atualizado há ${diff.inSeconds}s';
  if (diff.inMinutes < 60) return 'Atualizado há ${diff.inMinutes}m';
  return 'Atualizado há ${diff.inHours}h';
}
