import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/binance_api.dart';
import 'package:velocambio/datasource/services/cached_rate_service.dart';
import 'package:velocambio/models/adapters/cached_rate_adapter.dart';
import 'package:velocambio/models/rate_api_model.dart';

class BinanceProvider extends CmmGeneralProvider {
  double p2pPrice = 0.0;
  DateTime p2pUpdateDate = DateTime.now();
  bool p2pFromCache = false;

  late BinanceUSDTApi binanceP2PApi = BinanceUSDTApi();
  final CachedRateService _cache = CachedRateService();

  void loadFromCache() {
    final cached = _cache.get(CachedRateService.usdtP2pKey);
    if (cached != null) {
      p2pPrice = cached.price;
      p2pUpdateDate = cached.fetchedAt;
      p2pFromCache = true;
    }
  }

  Future<RateApiResponseModel> getBinanceP2pRate() async {
    log('Function getBinanceP2pRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      resp = await binanceP2PApi.getUSDT();

      p2pPrice = resp.price;
      p2pUpdateDate = resp.fetched_at;
      p2pFromCache = false;

      await _cache.save(
        CachedRateService.usdtP2pKey,
        CachedRateModel(
          price: resp.price,
          rateTypeCode: resp.rate_type_code,
          fetchedAt: resp.fetched_at,
        ),
      );
    } catch (e) {
      log('Error en BinanceProvider: $e');
      if (p2pPrice == 0) {
        final cached = _cache.get(CachedRateService.usdtP2pKey);
        if (cached != null) {
          p2pPrice = cached.price;
          p2pUpdateDate = cached.fetchedAt;
          p2pFromCache = true;
        }
      }
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }
}
