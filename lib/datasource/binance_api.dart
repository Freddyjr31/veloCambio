import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/binance_dio.dart' show binanceDio;
import 'package:velocambio/models/binance_usdt_model.dart';
import 'package:velocambio/providers/cmm_general_provider.dart';

class BinanceP2PApi extends CmmGeneralProvider {

  Future<BinanceP2PModel> getP2pRate() async {
    late BinanceP2PModel resp;

    try {
      super.setLoadingStatus(true);
      final req = await binanceDio.post(
        'bapi/c2c/v2/friendly/c2c/adv/search',
        data: {
          'asset': 'USDT',
          'fiat': 'VES',
          'merchantCheck': true,
          'page': 1,
          'rows': 10,
          'payTypes': [],
          'tradeType': 'SELL',
          'publisherType': null,
        },
      );

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');

        final data = req.data['data'] as List? ?? [];
        final ads = data.map((e) => BinanceAdModel.fromJson(e)).toList();

        double bestPrice = 0;
        if (ads.isNotEmpty) {
          bestPrice = ads.map((a) => a.price).reduce((a, b) => a < b ? a : b);
        }

        resp = BinanceP2PModel(
          bestPrice: bestPrice,
          updatedAt: DateTime.now(),
          ads: ads,
        );
      }

    } on SocketException {
      log('No hay internet', name: 'NO INTERNET - BINANCE');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      resp = BinanceP2PModel(bestPrice: 0, updatedAt: DateTime.now(), ads: []);
      super.setErrors(true);
      log('Error en Binance API: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }
}
