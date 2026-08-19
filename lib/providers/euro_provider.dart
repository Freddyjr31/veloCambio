import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/euro_api.dart';
import 'package:velocambio/datasource/services/cached_rate_service.dart';
import 'package:velocambio/models/adapters/cached_rate_adapter.dart';
import 'package:velocambio/models/rate_api_model.dart';

class EuroProvider extends CmmGeneralProvider {
  double oficialEuroRate = 0.0;
  DateTime oficialEuroRateUpdateDate = DateTime.now();
  bool oficialEuroRateFromCache = false;

  void setEuroRate(double val) {
    oficialEuroRate = val;
    notifyListeners();
  }

  void setEuroRateUpdateDate(DateTime val) {
    oficialEuroRateUpdateDate = val;
    notifyListeners();
  }

  late EuroRateApi eurosExchangeRateApi = EuroRateApi();
  final CachedRateService _cache = CachedRateService();

  void loadFromCache() {
    final cached = _cache.get(CachedRateService.eurKey);
    if (cached != null) {
      oficialEuroRate = cached.price;
      oficialEuroRateUpdateDate = cached.fetchedAt;
      oficialEuroRateFromCache = true;
    }
  }

  Future<RateApiResponseModel> getEurosExchangeRate() async {
    log('Function getEurosExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      resp = await eurosExchangeRateApi.getExchangeRate();
      log('Respuesta de la API: $resp');

      oficialEuroRate = resp.price;
      oficialEuroRateUpdateDate = resp.fetched_at;
      oficialEuroRateFromCache = false;

      await _cache.save(
        CachedRateService.eurKey,
        CachedRateModel(
          price: resp.price,
          rateTypeCode: resp.rate_type_code,
          fetchedAt: resp.fetched_at,
        ),
      );
    } catch (e) {
      log('Error en el provider: $e');
      if (oficialEuroRate == 0) {
        final cached = _cache.get(CachedRateService.eurKey);
        if (cached != null) {
          oficialEuroRate = cached.price;
          oficialEuroRateUpdateDate = cached.fetchedAt;
          oficialEuroRateFromCache = true;
        }
      }
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }
}
