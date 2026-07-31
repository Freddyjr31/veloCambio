
import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/euro_api.dart';
import 'package:velocambio/models/rate_api_model.dart';

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

  // late EuroExchangeRateApi eurosExchangeRateApi = EuroExchangeRateApi();
  late EuroRateApi eurosExchangeRateApi = EuroRateApi();

  Future<RateApiResponseModel> getEurosExchangeRate() async {
    
    log('Function getEurosExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try{
      
      resp = await eurosExchangeRateApi.getExchangeRate();
      log('Respuesta de la API: $resp');

      oficialEuroRate = resp.price;
      oficialEuroRateUpdateDate = resp.fetched_at;

    } catch (e) {
      // Aquí podrías manejar el error de forma global
      log('Error en el provider: $e');
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }

}