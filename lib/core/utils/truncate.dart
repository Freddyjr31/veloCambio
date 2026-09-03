import 'dart:math' as math;

/// Trunca (no redondea) un [value] a [decimals] decimales.
///
/// A diferencia de [double.toStringAsFixed] o
/// [NumberFormat]/`decimalDigits`, que redondean al dígito más cercano,
/// esta función descarta los decimales por encima de [decimals] sin subir
/// el último dígito conservado. Ejemplo: `truncateTo(804.8109, 3)` devuelve
/// `804.810` (no `804.811`).
double truncateTo(double value, int decimals) {
  final factor = math.pow(10, decimals).toDouble();
  return (value * factor).truncateToDouble() / factor;
}
