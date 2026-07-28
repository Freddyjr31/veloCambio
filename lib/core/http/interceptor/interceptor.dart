import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';

class CustomInterceptors extends Interceptor {
  
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

    String errorMsg = 'Error de conexion';
    if (err.message != null && !err.message!.contains('SocketException')) {
      errorMsg = 'Error: ${err.message}';
    }

    toastification.show(
      title: Text('Error'),
      description: Text(errorMsg),
      type: ToastificationType.error
    );
    
    super.onError(err, handler);
  }
}