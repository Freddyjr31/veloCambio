import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/multi_item_model.dart';

/// Proveedor de la calculadora multi-items.
///
/// Permite evaluar varios montos en simultáneo, cada uno con su propia
/// tasa editable (por defecto hereda la tasa global seleccionada en Inicio).
/// El estado vive únicamente en memoria (no se persiste en Hive).
class MultiItemsProvider extends CmmGeneralProvider {
  /// Items agregados por el usuario.
  List<MultiItem> items = [];

  /// Tasa por defecto para los nuevos items (heredada de la calculadora).
  double defaultRate = 0;

  /// Total de todos los resultados según la tasa global vigente.
  double totalFor(double globalRate) =>
      items.fold(0, (sum, item) => sum + item.resultFor(globalRate));

  /// Actualiza la tasa por defecto que toman los nuevos items.
  void setDefaultRate(double rate) {
    defaultRate = rate;
    notifyListeners();
  }

  /// Agrega un nuevo item.
  void addItem({double amount = 0, double? rate}) {
    items.add(
      MultiItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amount,
        customRate: rate,
        useGlobalRate: rate == null,
      ),
    );
    notifyListeners();
  }

  /// Elimina un item por índice.
  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    notifyListeners();
  }

  /// Actualiza el monto base de un item.
  void updateAmount(int index, double value) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(amount: value);
    notifyListeners();
  }

  /// Actualiza la tasa propia de un item (lo saca de la tasa global).
  void updateRate(int index, double value) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(
      customRate: value,
      useGlobalRate: false,
    );
    notifyListeners();
  }

  /// Cambia un item a tasa propia, inicializando su cotización
  /// con la tasa global vigente.
  void useCustomRate(int index, {required double globalRate}) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(
      customRate: globalRate,
      useGlobalRate: false,
    );
    notifyListeners();
  }

  /// Restaura la tasa global en un item (descarta su cotización propia).
  void restoreGlobalRate(int index) {
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(useGlobalRate: true);
    notifyListeners();
  }

  /// Limpia todos los items.
  void clearItems() {
    items = [];
    notifyListeners();
  }

  @override
  void disposeValues() {
    super.disposeValues();
    items = [];
    defaultRate = 0;
  }
}
