import 'package:intl/intl.dart';
import 'package:velocambio/core/utils/truncate.dart';

/// Trunca (no redondea) el [value] a 3 decimales antes de formatearlo.
String formatDolarTrunc(double value) =>
    formatoDolar.format(truncateTo(value, 3));

/// Trunca (no redondea) el [value] a 3 decimales antes de formatearlo.
String formatBolivarTrunc(double value) =>
    formatoBolivar.format(truncateTo(value, 3));

/// Trunca (no redondea) el [value] a 3 decimales antes de formatearlo.
String formatEuroTrunc(double value) => formatoEuro.format(truncateTo(value, 3));

/// Formatos de moneda en USD
final formatoDolar = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 3,
);

/// Formatos de moneda en VES
final formatoBolivar = NumberFormat.currency(
  locale: 'es_VE',
  symbol: 'VES',
  decimalDigits: 3,
);

/// Formatos de moneda en EUR
final formatoEuro = NumberFormat.currency(
  locale: 'en_US',
  symbol: '€',
  decimalDigits: 3,
);
