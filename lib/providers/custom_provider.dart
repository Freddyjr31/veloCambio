import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/adapters/custom_model_adapter.dart';

class CustomProvider extends CmmGeneralProvider {
  TextEditingController customAmountController = TextEditingController();

  List<CustomModel> customModels = [];

  List<CustomModel> getCustomModels() => customModels;

  //* item del listado marcado o en uso
  CustomModel? selectedCustomModel;

  void setCustomModel(CustomModel customModel) {
    selectedCustomModel = customModel;
    notifyListeners();
  }

  void removeCustomModel(CustomModel customModel) {
    selectedCustomModel = null;
    notifyListeners();
  }

  Future<bool> insertCustomDataSource(CustomModel data) async {
    //* recibo la data yu la guardo en el box de Hive
    try {
      final box = await Hive.openBox<CustomModel>('custom_models');
      await box.add(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
