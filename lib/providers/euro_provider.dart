
import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/euro_api.dart';
import 'package:velocambio/models/euro_model.dart';

class EuroProvider extends CmmGeneralProvider {

  double oficialEuroRate = 0.0;
  DateTime oficialEuroRateUpdateDate = DateTime.now();

  void setEuroRate(double val) {
    oficialEuroRate = val;
    notifyListeners();
  }

  void setEuroRateUpdateDate(DateTime val) {
    oficialEuroRateUpdateDate = val;
    notifyListeners();
  }

  late EuroExchangeRateApi eurosExchangeRateApi = EuroExchangeRateApi();

  Future<EuroExchangeModel> getEurosExchangeRate() async {
    
    log('Function getEurosExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    try{
      
      EuroExchangeModel resp = await eurosExchangeRateApi.getExchangeRate();
      log('Respuesta de la API: ${resp.exchange.toList()}');
      log(resp.toString());

      oficialEuroRate = resp.exchange[0].promedio;
      // amount = oficialEuroRate;
      oficialEuroRateUpdateDate = resp.exchange[0].fechaActualizacion!;

      log('Oficial: $oficialEuroRate');
      log('Oficial: $oficialEuroRateUpdateDate');

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

}