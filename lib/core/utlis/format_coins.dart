import 'package:intl/intl.dart';

/// Formatos de moneda en USD
final formatoDolar = NumberFormat.currency(
  locale: 'en_US', 
  symbol: '\$', 
  decimalDigits: 3
  );
/// Formatos de moneda en VES
final formatoBolivar = NumberFormat.currency(
  locale: 'es_VE',
  symbol: 'VES',
  decimalDigits: 3
);

/// Formatos de moneda en EUR
final formatoEuro = NumberFormat.currency(
  locale: 'en_US', 
  symbol: '€', 
  decimalDigits: 3
  );