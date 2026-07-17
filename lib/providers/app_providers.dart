
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:velocambio/providers/cmm_general_provider.dart';
import 'package:velocambio/providers/coin_provider.dart';
import 'package:velocambio/providers/conectivity_status_provider.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/binance_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/exchange_rate_provider.dart';

class AppProviders extends ChangeNotifier {

  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<CmmGeneralProvider>(create: (_) => CmmGeneralProvider()),
    ChangeNotifierProvider<UsdExchangeRateProvider>(create: (_) => UsdExchangeRateProvider()),
    ChangeNotifierProvider<CoinProvider>(create: (_) => CoinProvider()),
    ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider<EuroProvider>(create: (_) => EuroProvider()),
    ChangeNotifierProvider<CustomProvider>(create: (_) => CustomProvider()),
    ChangeNotifierProvider<BinanceProvider>(create: (_) => BinanceProvider()),
  ];

  static List<CmmGeneralProvider> getDisposeProviders(BuildContext context) {
    return [
      context.read<CmmGeneralProvider>(),
      context.read<UsdExchangeRateProvider>(),
      context.read<CoinProvider>(),
      context.read<ConnectivityProvider>(),
      context.read<EuroProvider>(),
      context.read<CustomProvider>(),
      context.read<BinanceProvider>()
    ];
  }

  static void disposeAllProviders(BuildContext context) {
    getDisposeProviders(context).forEach((disposableProvider) {
      disposableProvider
        ..disposeValues()
        ..resetValues();
    });
  }
}