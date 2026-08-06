
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:velocambio/core/http/interceptor/interceptor.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: '',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
)..interceptors.addAll([
  CustomInterceptors(),
  
  if(kDebugMode)
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false, // Puedes ponerlo en true si necesitas ver los headers de respuesta
      error: true,
      compact: true,
      maxWidth: 90, // Ancho de la línea divisoria en la consola
    ),
  ]);


