import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/binance_api.dart';
import 'package:velocambio/models/rate_api_model.dart';

class BinanceProvider extends CmmGeneralProvider {

  double p2pPrice = 0.0;
  DateTime p2pUpdateDate = DateTime.now();

  // late BinanceP2PApi binanceP2pApi = BinanceP2PApi();
  late BinanceUSDTApi binanceP2PApi = BinanceUSDTApi();

  Future<RateApiResponseModel> getBinanceP2pRate() async {

    log('Function getBinanceP2pRate');
    super.setLoadingStatus(true);
    notifyListeners();

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      resp = await binanceP2PApi.getUSDT();

      p2pPrice = resp.price;
      p2pUpdateDate = resp.fetched_at;

    } catch (e) {
      log('Error en BinanceProvider: $e');
    } finally {
      super.setLoadingStatus(false);
      notifyListeners();
    }

    return resp;
  }
}
