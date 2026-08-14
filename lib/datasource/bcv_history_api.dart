import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:velocambio/core/http/dio_client.dart' show dio;
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/models/bcv_history_model.dart';

/// Datasource encargado de consumir el histórico de tasas BCV del backend.
///
/// Endpoint: `GET rates/historico/bcv?page=X&page_size=Y`
/// La API devuelve cada página en orden ascendente (más viejo -> más reciente).
class BcvHistoryApi extends CmmGeneralProvider {
  Future<BcvHistoryResponseModel> getHistory({
    required int page,
    int pageSize = 50,
  }) async {
    BcvHistoryResponseModel resp = BcvHistoryResponseModel(
      currency: '',
      rate_type: '',
      source: '',
      page: 0,
      page_size: 0,
      total: 0,
      total_pages: 0,
      history: [],
    );

    try {
      super.setLoadingStatus(true);

      final req = await dio.get(
        'rates/historico/bcv',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      super.setStatusCode(req.statusCode!);

      if (req.statusCode == HttpStatus.ok) {
        super.setErrors(false);
        super.setErrorMessage('');
        resp = BcvHistoryResponseModel.fromJson(req.data);
        log(
          'Histórico obtenido: ${resp.history.length} registros '
          '(página ${resp.page}/${resp.total_pages})',
          name: 'BCV HISTORY API',
        );
      }
    } on SocketException {
      log('No hay internet', name: 'NO INTERNET - HISTORICO BCV');
      throw Exception('No hay internet');
    } on DioException catch (e) {
      super.setErrors(true);
      log('Error en el histórico: $e', stackTrace: StackTrace.current);
    }

    notifyListeners();
    return resp;
  }
}
