import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/core/services/home_widget_service.dart';
import 'package:velocambio/datasource/services/cached_rate_service.dart';
import 'package:velocambio/datasource/usd_api.dart';
import 'package:velocambio/models/adapters/cached_rate_adapter.dart';
import 'package:velocambio/models/rate_api_model.dart';

class UsdExchangeRateProvider extends CmmGeneralProvider {
  TextEditingController amountController = TextEditingController();

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

  // late UsdsExchangeRateApi usdsExchangeRateApi = UsdsExchangeRateApi();
  late UsdRateApi usdsExchangeRateApi = UsdRateApi();
  final CachedRateService _cache = CachedRateService();

  bool oficialRateFromCache = false;
  bool averageRateFromCache = false;

  void loadFromCache() {
    final oficialCached = _cache.get(CachedRateService.usdOficialKey);
    if (oficialCached != null) {
      oficialRate = oficialCached.price;
      oficialRateUpdateDate = oficialCached.fetchedAt;
      oficialRateFromCache = true;
    }

    final averageCached = _cache.get(CachedRateService.usdMarketKey);
    if (averageCached != null) {
      averageRate = averageCached.price;
      averageRateUpdateDate = averageCached.fetchedAt;
      averageRateFromCache = true;
    }
  }

  Future<RateApiResponseModel> getUsdExchangeRate() async {
    log('Function getUsdExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      resp = await usdsExchangeRateApi.getUsdOfficial();
      debugPrint('Respuesta de la API: $resp');

      oficialRate = resp.price;
      oficialRateUpdateDate = resp.fetched_at;
      oficialRateFromCache = false;

      await _cache.save(
        CachedRateService.usdOficialKey,
        CachedRateModel(
          price: resp.price,
          rateTypeCode: resp.rate_type_code,
          fetchedAt: resp.fetched_at,
        ),
      );

      if (resp.price > 0) {
        await HomeWidgetService.syncBcvRateToWidget(resp);
      }
    } catch (e) {
      log('Error en el provider: $e');
      if (oficialRate == 0) {
        final cached = _cache.get(CachedRateService.usdOficialKey);
        if (cached != null) {
          oficialRate = cached.price;
          oficialRateUpdateDate = cached.fetchedAt;
          oficialRateFromCache = true;
        }
      }
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }

  Future<RateApiResponseModel> getUsdMarketExchangeRate() async {
    log('Function getUsdExchangeRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      resp = await usdsExchangeRateApi.getUsdMarket();
      debugPrint('Respuesta de la API: $resp');
      debugPrint(resp.toString());

      averageRate = resp.price;
      averageRateUpdateDate = resp.fetched_at;
      averageRateFromCache = false;

      await _cache.save(
        CachedRateService.usdMarketKey,
        CachedRateModel(
          price: resp.price,
          rateTypeCode: resp.rate_type_code,
          fetchedAt: resp.fetched_at,
        ),
      );
    } catch (e) {
      log('Error en el provider: $e');
      if (averageRate == 0) {
        final cached = _cache.get(CachedRateService.usdMarketKey);
        if (cached != null) {
          averageRate = cached.price;
          averageRateUpdateDate = cached.fetchedAt;
          averageRateFromCache = true;
        }
      }
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }

  @override
  void disposeValues() {
    super.disposeValues();
    setOficialRate(0);
    setAverageRate(0);
    setOficialRateUpValue(false);
    setAverageRateUpValue(false);
  }
}
