import 'package:dio/dio.dart';
import 'package:velocambio/core/http/interceptor/interceptor.dart';

final binanceDio = Dio(
  BaseOptions(
    baseUrl: 'https://p2p.binance.com/',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    },
  ),
)..interceptors.addAll([
  CustomInterceptors(),

  // if(kDebugMode)
  //   PrettyDioLogger(
  //     requestHeader: true,
  //     requestBody: true,
  //     responseBody: true,
  //     responseHeader: false,
  //     error: true,
  //     compact: true,
  //     maxWidth: 90,
  //   ),
  ]
  );
