import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/rates_stats_api.dart';
import 'package:velocambio/models/brecha_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/models/variacion_model.dart';

class RatesStatsProvider extends CmmGeneralProvider {

  late RatesStatsApi ratesStatsApi = RatesStatsApi();

  BrechaResponseModel brecha = BrechaResponseModel.empty();
  VariacionesResponseModel variaciones = VariacionesResponseModel.empty();

  bool brechaLoaded = false;
  bool variacionesLoaded = false;

  Future<void> getBrechas() async {
    log('Function getBrechas');
    super.setLoadingStatus(true);
    notifyListeners();

    try {
      brecha = await ratesStatsApi.getBrecha();
      brechaLoaded = brecha.usdOficialPrice > 0;
    } catch (e) {
      log('Error en el provider: $e');
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }
  }

  Future<void> getVariaciones() async {
    log('Function getVariaciones');
    super.setLoadingStatus(true);
    notifyListeners();

    try {
      variaciones = await ratesStatsApi.getVariaciones();
      variacionesLoaded = variaciones.usdOficial.price > 0;
    } catch (e) {
      log('Error en el provider: $e');
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }
  }

  Future<void> getStats() async {
    await getBrechas();
    await getVariaciones();
  }

  double? brechaDe(ExchangeType type) {
    if (!brechaLoaded) return null;
    switch (type) {
      case ExchangeType.averageUsd:
        return brecha.usdParalelo.brecha;
      case ExchangeType.oficialEur:
        return brecha.eur.brecha;
      case ExchangeType.p2pUsdt:
        return brecha.usdt.brecha;
      case ExchangeType.oficialUsd:
      case ExchangeType.custom:
        return null;
    }
  }

  double? variacion24hDe(ExchangeType type) {
    if (!variacionesLoaded) return null;
    switch (type) {
      case ExchangeType.oficialUsd:
        return variaciones.usdOficial.variacion24h;
      case ExchangeType.averageUsd:
        return variaciones.usdParalelo.variacion24h;
      case ExchangeType.oficialEur:
        return variaciones.eur.variacion24h;
      case ExchangeType.p2pUsdt:
        return variaciones.usdt.variacion24h;
      case ExchangeType.custom:
        return null;
    }
  }

  double? variacion7dDe(ExchangeType type) {
    if (!variacionesLoaded) return null;
    switch (type) {
      case ExchangeType.oficialUsd:
        return variaciones.usdOficial.variacion7d;
      case ExchangeType.averageUsd:
        return variaciones.usdParalelo.variacion7d;
      case ExchangeType.oficialEur:
        return variaciones.eur.variacion7d;
      case ExchangeType.p2pUsdt:
        return variaciones.usdt.variacion7d;
      case ExchangeType.custom:
        return null;
    }
  }

  @override
  void disposeValues() {
    super.disposeValues();
    brecha = BrechaResponseModel.empty();
    variaciones = VariacionesResponseModel.empty();
    brechaLoaded = false;
    variacionesLoaded = false;
  }
}
