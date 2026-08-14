/// Utilidades de operaciones matemáticas aplicadas a tasas y montos.
///
/// Funciones puras usadas por el modal de operaciones
/// (porcentajes, sumar/restar valores).
class OperationsCalculator {
  /// Suma o resta un valor fijo a un monto base.
  static double applyValue({
    required double base,
    required double value,
    required bool subtract,
  }) {
    return subtract ? base - value : base + value;
  }

  /// Suma o resta un porcentaje (%) a un monto base.
  ///
  /// Ejemplo: base = 855.55 y percentage = 5 suma el 5% (42.77).
  static double applyPercentage({
    required double base,
    required double percentage,
    required bool subtract,
  }) {
    final delta = base * (percentage / 100);
    return subtract ? base - delta : base + delta;
  }

  /// Calcula el monto correspondiente a un porcentaje de otro monto.
  ///
  /// Ejemplo: amount = 855.55 y percentage = 10 responde 85.555
  /// (cuánto es el 10% del monto).
  static double percentageOf({
    required double amount,
    required double percentage,
  }) {
    return amount * (percentage / 100);
  }

  /// Calcula qué porcentaje representa [part] sobre [total].
  static double percentOf({required double part, required double total}) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }
}
