import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/app.dart';
import 'package:velocambio/core/config/app_config.dart';
// import 'package:velocambio/core/http/binance_dio.dart';
import 'package:velocambio/core/http/dio_client.dart';
import 'package:velocambio/models/adapters/cached_rate_adapter.dart';
import 'package:velocambio/datasource/services/cached_rate_service.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart';
import 'package:velocambio/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await AppConfig.loadEnv();
  dio.options.baseUrl = AppConfig.baseUrl;
  // binanceDio.options.baseUrl = AppConfig.baseUrl;

  //* Admob
  await MobileAds.instance.initialize();

  try {
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/velocambio/hive';
    await Hive.initFlutter(path);

    Hive.registerAdapter(CurrencyHistoryModelAdapter());
    Hive.registerAdapter(CachedRateModelAdapter());

    await Hive.openBox<CachedRateModel>(CachedRateService.boxName);
  } on Exception catch (e) {
    log(e.toString(), name: 'MAIN - INITIALIZE');
  }

  ErrorWidget
      .builder = (FlutterErrorDetails details, {StackTrace? stackTrace}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: SafeArea(
          child: Container(
            color: Colors.red[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.error, color: Colors.red, size: 100),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Ha ocurrido un error inesperado',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  };

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const MainApp()),
  );
}
