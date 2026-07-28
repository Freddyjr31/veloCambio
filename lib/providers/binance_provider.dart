import 'dart:developer';

import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/datasource/binance_api.dart';
import 'package:velocambio/models/binance_usdt_model.dart';

class BinanceProvider extends CmmGeneralProvider {

  double p2pPrice = 0.0;
  DateTime p2pUpdateDate = DateTime.now();

  late BinanceP2PApi binanceP2pApi = BinanceP2PApi();

  Future<BinanceP2PModel> getBinanceP2pRate() async {
    log('Function getBinanceP2pRate');
    super.setLoadingStatus(true);
    notifyListeners();

    try {
      BinanceP2PModel resp = await binanceP2pApi.getP2pRate();

      p2pPrice = resp.bestPrice;
      p2pUpdateDate = resp.updatedAt;

      //log('P2P Best Price: $p2pPrice');
      super.setLoadingStatus(false);
      notifyListeners();
      return resp;
    } catch (e) {
      log('Error en BinanceProvider: $e');
      //super.setLoadingStatus(false);
      throw Exception('Failed to fetch P2P rate: $e');
    } finally {
      notifyListeners();
    }
  }
}
