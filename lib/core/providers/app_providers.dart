import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:velocambio/core/providers/cmm_general_provider.dart';
import 'package:velocambio/core/providers/conectivity_status_provider.dart';
import 'package:velocambio/providers/binance_provider.dart';
import 'package:velocambio/providers/bcv_history_provider.dart';
import 'package:velocambio/providers/coin_provider.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/exchange_rate_provider.dart';
import 'package:velocambio/providers/multi_items_provider.dart';
import 'package:velocambio/providers/rates_stats_provider.dart';

class AppProviders extends ChangeNotifier {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<CmmGeneralProvider>(
      create: (_) => CmmGeneralProvider(),
    ),
    ChangeNotifierProvider<UsdExchangeRateProvider>(
      create: (_) => UsdExchangeRateProvider(),
    ),
    ChangeNotifierProvider<CoinProvider>(create: (_) => CoinProvider()),
    ChangeNotifierProvider<ConnectivityProvider>(
      create: (_) => ConnectivityProvider(),
    ),
    ChangeNotifierProvider<EuroProvider>(create: (_) => EuroProvider()),
    ChangeNotifierProvider<CustomProvider>(create: (_) => CustomProvider()),
    ChangeNotifierProvider<BinanceProvider>(create: (_) => BinanceProvider()),
    ChangeNotifierProvider<RatesStatsProvider>(
      create: (_) => RatesStatsProvider(),
    ),
    ChangeNotifierProvider<BcvHistoryProvider>(
      create: (_) => BcvHistoryProvider(),
    ),
    ChangeNotifierProvider<MultiItemsProvider>(
      create: (_) => MultiItemsProvider(),
    ),
  ];

  static List<CmmGeneralProvider> getDisposeProviders(BuildContext context) {
    return [
      context.read<CmmGeneralProvider>(),
      context.read<UsdExchangeRateProvider>(),
      context.read<CoinProvider>(),
      context.read<ConnectivityProvider>(),
      context.read<EuroProvider>(),
      context.read<CustomProvider>(),
      context.read<BinanceProvider>(),
      context.read<RatesStatsProvider>(),
      context.read<BcvHistoryProvider>(),
      context.read<MultiItemsProvider>(),
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
