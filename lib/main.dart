import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocambio/app.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart';
import 'package:velocambio/models/adapters/custom_model_adapter.dart';
import 'package:velocambio/models/adapters/euro_model_adapter.dart';
import 'package:velocambio/models/adapters/usd_bcv_model_adapter.dart';
import 'package:velocambio/models/adapters/usd_market_model_adapter.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try {
    
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/velocambio/hive';
    await Hive.initFlutter(path);

    Hive.registerAdapter(CurrencyHistoryModelAdapter());

    Hive.registerAdapter(UsdBcvModelAdapter());
    Hive.registerAdapter(UsdMarketModelAdapter());
    Hive.registerAdapter(EuroModelAdapter());
    Hive.registerAdapter(CustomModelAdapter());

    await Hive.openBox<UsdBcvModel>('bcv_box');
    await Hive.openBox<UsdMarketModel>('promedio_box');
    await Hive.openBox<EuroModel>('euro_box');
    await Hive.openBox<CustomModel>('custom_box');

    // await Supabase.initialize(
    //   url: 'https://amrtpbpkhqidjosujefk.supabase.co',
    //   anonKey: 'sb_publishable_HZdw1B_-l2vmnDNBZXrSLw_m_vy0GUo',
    // );

  } on Exception catch (e) {
    log(e.toString(), name: 'MAIN - INITIALIZE');
  }

  ErrorWidget.builder = (FlutterErrorDetails details, {StackTrace? stackTrace}) {
    return Material(
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
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 100,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Error: ${details.exception}',
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
      )
    );
  };

  runApp(
    const MainApp()
    );
}


// final supabase = Supabase.instance.client;
