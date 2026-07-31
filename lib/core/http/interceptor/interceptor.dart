import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';

class CustomInterceptors extends Interceptor {

  //* Agrupación de errores consecutivos (ej. falla de todos los endpoints al arrancar)
  Timer? _errorDebounce;
  final List<(String, String)> _pendingErrors = [];
  static const Duration _debounceWindow = Duration(milliseconds: 900);

  //* Nombres amigables por endpoint
  static const Map<String, String> _endpointLabels = {
    'rates/usd_oficial': 'Dólar BCV Oficial',
    'rates/usd_promedio': 'Dólar Promedio',
    'rates/eur': 'Euro',
    'rates/usdt': 'USDT P2P',
    'bapi/c2c/v2/friendly/c2c/adv/search': 'USDT P2P',
    'v1/dolares': 'Dólar',
    'v1/euros': 'Euro',
  };

  String? _endpointLabel(DioException err) {
    final path = err.requestOptions.path.replaceFirst(RegExp(r'^/+'), '');
    return _endpointLabels[path];
  }

  String _friendlyErrorMessage(DioException err) {

    //* 1. Prioridad: mensaje del backend (campo "detail")
    final data = err.response?.data;
    if (data is Map) {
      final detail = data['detail']?.toString();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
    }

    //* 2. Por tipo de excepción de Dio
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Revisa tu conexión';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu internet';
      case DioExceptionType.badCertificate:
        return 'Error de seguridad de la conexión';
      case DioExceptionType.cancel:
        return 'Solicitud cancelada';
      case DioExceptionType.badResponse:
        break; // se mapea por código HTTP abajo
      case DioExceptionType.unknown:
        if (err.message?.contains('SocketException') ?? false) {
          return 'Error de conexión. Verifica tu internet';
        }
        break; // fallback genérico
    }

    //* 3. Por código HTTP
    switch (err.response?.statusCode) {
      case 400:
        return 'Solicitud inválida';
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'No encontrado';
      case 408:
        return 'Tiempo de espera agotado';
      case 429:
        return 'Demasiadas solicitudes. Intenta más tarde';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Error en el servidor. Intenta más tarde';
      default:
        return 'Error inesperado. Intenta de nuevo';
    }
  }

  void _showPendingErrors() {
    if (_pendingErrors.isEmpty) return;

    if (_pendingErrors.length > 1) {
      //* Varios endpoints fallaron → toast único y limpio
      toastification.show(
        title: const Text('Error'),
        description: const Text('No se pudieron cargar las tasas. Revisa tu conexión'),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored
      );
    } else {
      //* Un solo error → indica qué moneda falló
      final (currency, message) = _pendingErrors.single;
      toastification.show(
        title: Text(currency),
        description: Text(message),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored
      );
    }

    _pendingErrors.clear();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('REQUEST[${options.method}] => PATH: ${options.path}', name: 'HTTP');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}', name: 'HTTP');
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {

    log('ERROR [${err.message}]', name: 'HTTP');

    final currency = _endpointLabel(err) ?? 'Error';
    final message = _friendlyErrorMessage(err);

    _pendingErrors.add((currency, message));

    _errorDebounce?.cancel();
    _errorDebounce = Timer(_debounceWindow, _showPendingErrors);

    super.onError(err, handler);
  }
}
