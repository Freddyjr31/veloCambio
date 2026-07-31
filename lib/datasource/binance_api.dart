import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/binance_dio.dart' show binanceDio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/rate_api_model.dart';

// class BinanceP2PApi extends CmmGeneralProvider {

//   Future<BinanceP2PModel> getP2pRate() async {

//     late BinanceP2PModel resp;

//     try {
//       final req = await binanceDio.post(
//         'bapi/c2c/v2/friendly/c2c/adv/search',
//         data: {
//           'asset': 'USDT',
//           'fiat': 'VES',
//           'merchantCheck': true,
//           'page': 1,
//           'rows': 10,
//           'payTypes': [],
//           'tradeType': 'SELL',
//           'publisherType': null,
//         },
//       );

//       super.setStatusCode(req.statusCode!);

//       if (req.statusCode == HttpStatus.ok) {
//         super.setErrors(false);
//         super.setErrorMessage('');

//         final data = req.data['data'] as List? ?? [];
//         final ads = data.map((e) => BinanceAdModel.fromJson(e)).toList();

//         double bestPrice = 0;
//         if (ads.isNotEmpty) {
//           bestPrice = ads.map((a) => a.price).reduce((a, b) => a < b ? a : b);
//         }

//         resp = BinanceP2PModel(
//           bestPrice: bestPrice,
//           updatedAt: DateTime.now(),
//           ads: ads,
//         );
//       }

//     } on SocketException {
//       log('No hay internet', name: 'NO INTERNET - BINANCE');
//       throw Exception('No hay internet');
//     } on DioException catch (e) {
//       resp = BinanceP2PModel(bestPrice: 0, updatedAt: DateTime.now(), ads: []);
//       super.setErrors(true);
//       log('Error en Binance API: $e', stackTrace: StackTrace.current);
//     }

//     notifyListeners();
//     return resp;
//   }
// }


class BinanceUSDTApi extends CmmGeneralProvider {

  Future<RateApiResponseModel> getUSDT() async {

    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      super.setLoadingStatus(true);
      final req = await binanceDio.get('rates/usdt');
      log(req.data.toString());

      super.setStatusCode(req.statusCode!);
      notifyListeners();

      if(req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = RateApiResponseModel.fromJson(req.data);
        log("Response convertida: $resp tipos de cambio encontrados");
      }

      super.setLoadingStatus(false);
      
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET - BINANCE');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      super.setErrors(true);
      resp = RateApiResponseModel(
        price: 0,
        source_type_code: '',
        currency_from_code: '',
        currency_to_code: '',
        rate_type_code: '',
        fetched_at: DateTime.now(),
      );
      log('Error en Binance API: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }
}
