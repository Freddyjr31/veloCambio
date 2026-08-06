import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:velocambio/core/http/interceptor/interceptor.dart';

final binanceDio = Dio(
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
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  ]
  );
