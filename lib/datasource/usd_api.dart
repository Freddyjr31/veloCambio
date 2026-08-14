import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/dio_client.dart' show dio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/rate_api_model.dart';

// class UsdsExchangeRateApi extends CmmGeneralProvider {

//   Future<UsdExchangeModel> getExchangeRate() async {

//    late UsdExchangeModel resp;

//     try {
//       super.setLoadingStatus(true);

//       final req = await dio.get('v1/dolares');

//       super.setStatusCode(req.statusCode!);

//       if (req.statusCode == HttpStatus.ok) {
//         super.setErrors(false);
//         super.setErrorMessage('');

//         // log('${req.data}');
//         resp = UsdExchangeModel.fromList(req.data);
//         super.setLoadingStatus(false);
//         // log("Response convertida: ${resp.exchange.length} tipos de cambio encontrados");
//       }

//     } on SocketException {
//       log('No hay internet', name: 'NO INTERNET');
//       throw Exception('No hay internet');
//     } on DioException catch (e) {

//       resp = UsdExchangeModel(exchange: []);
//       super.setErrors(true);
//       log('Error en el provider: $e', stackTrace: StackTrace.current);
//     }

//     notifyListeners();

//     return resp;
//   }
// }

class UsdRateApi extends CmmGeneralProvider {
  Future<RateApiResponseModel> getUsdOfficial() async {
    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('rates/usd_oficial');
      log(req.data.toString());
      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = RateApiResponseModel.fromJson(req.data);
        log("Response convertida: $resp tipos de cambio encontrados");
      }
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      resp = RateApiResponseModel(
        price: 0,
        source_type_code: '',
        currency_from_code: '',
        currency_to_code: '',
        rate_type_code: '',
        fetched_at: DateTime.now(),
      );
      log('Error en el provider: $e', stackTrace: StackTrace.current);
      super.setErrors(true);
    }

    notifyListeners();
    return resp;
  }

  Future<RateApiResponseModel> getUsdMarket() async {
    RateApiResponseModel resp = RateApiResponseModel.empty();

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('rates/usd_promedio');

      log(req.data.toString());
      super.setStatusCode(req.statusCode!);
      notifyListeners();

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = RateApiResponseModel.fromJson(req.data);
        log("Response convertida: $resp tipos de cambio encontrados");
      }
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      resp = RateApiResponseModel(
        price: 0,
        source_type_code: '',
        currency_from_code: '',
        currency_to_code: '',
        rate_type_code: '',
        fetched_at: DateTime.now(),
      );
      super.setErrors(true);
      log('Error en el provider: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }
}
