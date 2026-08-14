import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/dio_client.dart' show dio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/brecha_model.dart';
import 'package:velocambio/models/variacion_model.dart';

class RatesStatsApi extends CmmGeneralProvider {
  Future<BrechaResponseModel> getBrecha() async {
    BrechaResponseModel resp = BrechaResponseModel.empty();

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('rates/brecha');
      log(req.data.toString());

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = BrechaResponseModel.fromJson(req.data);
        log("Response convertida: $resp");
      }
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET - BRECHA');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      resp = BrechaResponseModel.empty();
      super.setErrors(true);
      log('Error en el provider: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }

  Future<VariacionesResponseModel> getVariaciones() async {
    VariacionesResponseModel resp = VariacionesResponseModel.empty();

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('rates/variaciones');
      log(req.data.toString());

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = VariacionesResponseModel.fromJson(req.data);
        log("Response convertida: $resp");
      }
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET - VARIACIONES');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      resp = VariacionesResponseModel.empty();
      super.setErrors(true);
      log('Error en el provider: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }
}
