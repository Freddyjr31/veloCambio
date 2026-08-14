/// Item individual de la calculadora multi-items.
///
/// Cada item tiene un monto base y una tasa de conversión.
/// Por defecto usa la tasa global seleccionada en la calculadora principal
/// ([MultiItem.useGlobalRate] == true); si el usuario edita su propia
/// cotización, se guarda en [customRate] y se marca [useGlobalRate] == false.
class MultiItem {
  final String id;
  double amount;
  double? customRate;
  bool useGlobalRate;

  MultiItem({
    required this.id,
    this.amount = 0,
    this.customRate,
    this.useGlobalRate = true,
  });

  /// Resultado convertido (en VES) según la tasa efectiva del item.
  double resultFor(double globalRate) {
    final effectiveRate = useGlobalRate ? globalRate : (customRate ?? 0);
    return amount * effectiveRate;
  }

  /// Copia del item con valores actualizables.
  MultiItem copyWith({
    double? amount,
    double? customRate,
    bool? useGlobalRate,
  }) {
    return MultiItem(
      id: id,
      amount: amount ?? this.amount,
      customRate: customRate ?? this.customRate,
      useGlobalRate: useGlobalRate ?? this.useGlobalRate,
    );
  }
}
