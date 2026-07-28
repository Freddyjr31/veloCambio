import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/dio_client.dart' show dio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/euro_model.dart';

class EuroExchangeRateApi extends CmmGeneralProvider {
  
  Future<EuroExchangeModel> getExchangeRate() async {

   late EuroExchangeModel resp;

    try {
      super.setLoadingStatus(true);
      final req = await dio.get('v1/euros');

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        
        resp = EuroExchangeModel.fromList(req.data);
        // log("Response convertida: ${resp.exchange.length} tipos de cambio encontrados");
      }

    } on SocketException {
      log('No hay internet', name: 'NO INTERNET');
      throw Exception('No hay internet');
    } on DioException catch (e) {

      resp = EuroExchangeModel(exchange: []);
      super.setErrors(true);
      log('Error en el provider: $e', stackTrace: StackTrace.current);
    }
    
    // Future.delayed(const Duration(seconds: 2), (){
    //  super.setLoadingStatus(false);
      notifyListeners();
    //});
      
    return resp;
  }

}