
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/dio_client.dart' show dio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/usd_model.dart';

class UsdsExchangeRateApi extends CmmGeneralProvider {
  
  Future<UsdExchangeModel> getExchangeRate() async {

   late UsdExchangeModel resp;

    try {
      super.setLoadingStatus(true);

      final req = await dio.get('v1/dolares');

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        
        // log('${req.data}');
        resp = UsdExchangeModel.fromList(req.data);
        super.setLoadingStatus(false);
        // log("Response convertida: ${resp.exchange.length} tipos de cambio encontrados");
      }

    } on SocketException {
      log('No hay internet', name: 'NO INTERNET');
      throw Exception('No hay internet');
    } on DioException catch (e) {

      resp = UsdExchangeModel(exchange: []);
      super.setErrors(true);
      log('Error en el provider: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
      
    return resp;
  }


  //* Api de historicos
  Future<UsdExchangeModel> getExchangeRateHistoric() async {

   late UsdExchangeModel resp;

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('v1/historicos/dolares');

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = UsdExchangeModel.fromList(req.data);
        super.setLoadingStatus(false);
        log("Response convertida: ${resp.exchange.length} tipos de cambio encontrados", name: 'CONVERT TO LIST');
      }

    } on DioException catch (e) {

      resp = UsdExchangeModel(exchange: []);
      super.setErrors(true);
      // Verificamos si hay respuesta del servidor antes de usar '!'
      if (e.response != null) {
        super.setErrorMessage('${e.message}');
        // super.setStatusCode(e.response?.statusCode ?? 500);
      } else {
        // Si e.response es null, es un error de conexión (timeout, sin internet, etc.)
        super.setErrorMessage(e.message ?? 'Error de conexión con el servidor');
        super.setStatusCode(500); // Código de error interno simulado
      }
    }
  
    notifyListeners();
  
    return resp;
  }
}