
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/usd_api.dart';
import 'package:velocambio/models/usd_model.dart';

class UsdExchangeRateProvider extends CmmGeneralProvider{

  TextEditingController amountController = TextEditingController();

  //* para cambiar el monto, ESTE ES EL VALOR PRINCIPAL QUE SE USA PARA CALCULAR EL MONTO EN LA OTRA MONEDA
  // double amount = 0;
  // void setAmount(double val) {
  //   amount = val;
  //   notifyListeners();
  // }


  //* Para saber si subio o bajo el valor de la tasa oficial
  bool oficialRateUpValue = false;
  void setOficialRateUpValue(bool val) {
    oficialRateUpValue = val;
    notifyListeners();
  }
  //* Para saber si subio o bajo el valor de la tasa promedio
  bool averageRateUpValue = false;
  void setAverageRateUpValue(bool val) {
    averageRateUpValue = val;
    notifyListeners();
  }

  //* Tasas
  double oficialRate = 0;
  void setOficialRate(double val) {
    oficialRate = val;
    notifyListeners();
  }

  double averageRate = 0;
  void setAverageRate(double val) {
    averageRate = val;
    notifyListeners();
  }

  //* Fecha de actualización
  DateTime oficialRateUpdateDate = DateTime.now();
  void setOficialUpdateDate(DateTime val) {
    oficialRateUpdateDate = val;
    notifyListeners();
  }

  DateTime averageRateUpdateDate = DateTime.now();
  void setAverageUpdateDate2(DateTime val) {
    averageRateUpdateDate = val;
    notifyListeners();
  }

  //* Porcentajes
  double oficialRatePercentage = 0;
  void setOficialRatePercentage(double val) {
    oficialRatePercentage = val;
    notifyListeners();
  }

  double averageRatePercentage = 0;
  void setAverageRatePercentage(double val) {
    averageRatePercentage = val;
    notifyListeners();
  }

  late UsdsExchangeRateApi usdsExchangeRateApi = UsdsExchangeRateApi();

  Future<UsdExchangeModel> getUsdExchangeRate() async {
    
    log('Function getUsdExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    try{
      
      UsdExchangeModel resp = await usdsExchangeRateApi.getExchangeRate();
      debugPrint('Respuesta de la API: ${resp.exchange.toList()}');
      debugPrint(resp.toString());

      oficialRate = resp.exchange[0].promedio;
      averageRate = resp.exchange[1].promedio;
      
      oficialRateUpdateDate = resp.exchange[0].fechaActualizacion!;
      averageRateUpdateDate = resp.exchange[1].fechaActualizacion!;

      log('Oficial: $oficialRate, Average: $averageRate');
      log('Oficial: $oficialRateUpdateDate, Average: $averageRateUpdateDate');

      notifyListeners();
      super.setLoadingStatus(false);
      return resp;

    } catch (e) {
      // Aquí podrías manejar el error de forma global
      log('Error en el provider: $e');
      super.setLoadingStatus(false);
      throw Exception('Failed to fetch exchange rate: $e');

    } finally {
      notifyListeners();
    }
  }

  //* Funcion solo para llamar al api de historico
  // Future<UsdExchangeModel> getUsdExchangeRateHistoric() async {

  //   log('Function HISTORICO', name: 'HISTORY');
  //   super.setLoadingStatus(true);
  //   notifyListeners();

  //   try{
  //       UsdExchangeModel resp = await usdsExchangeRateApi.getExchangeRateHistoric();
  //       return resp;
  //   } catch (e) {
  //     // Aquí podrías manejar el error de forma global
  //     log('Error en el provider: $e', name: 'getUsdExchangeRateHistory - HISTORY', error: e, stackTrace: StackTrace.current);
  //     throw Exception('Failed to fetch exchange rate: $e');

  //   } finally {
  //     super.setLoadingStatus(false);
  //     notifyListeners();
  //   }
  // }

  @override
  void disposeValues() {
    super.disposeValues();
    setOficialRate(0);
    setAverageRate(0);
    setOficialRateUpValue(false);
    setAverageRateUpValue(false);
  }

}