import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart';

class DatabaseHiveServices {
  static const String _boxName = 'dolar_history';

  // Abrir la caja (se puede llamar al inicio o en cada operación)
  Future<Box<CurrencyHistoryModel>> _getBox() async {
    return await Hive.openBox<CurrencyHistoryModel>(_boxName);
  }

  Future<List<CurrencyHistoryModel>> getFirstCurrencyHistory() async {
    final box = await _getBox();
    //*obtener solo el ultimo registro de la caja
    final list = box.values.toList().reversed.toList();
    return list;
  }

  Future<List<CurrencyHistoryModel>> getLastCurrencyHistory() async {
    final box = await _getBox();

    if (box.isEmpty) {
      return [];
    }

    // Obtenemos solo el último registro (el más reciente)
    final lastRecord = box.getAt(box.length - 1);

    return [lastRecord!];
  }

  //* Guardar un elemento
  Future<bool> saveCurrencyHistory(CurrencyHistoryModel item) async {
    final box = await _getBox();

    try {
      await box.add(item);
      log(
        'Insertado correctamente en la caja',
        name: 'HIVE - saveCurrencyHistory',
      );
      return true;
    } catch (e) {
      log('Error al insertar: $e', name: 'HIVE - insertPaymentDataSource');
      return false;
    }
  }
}
