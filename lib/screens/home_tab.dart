import 'dart:developer';

// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:toastification/toastification.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/models/adapters/currency_history_adapters.dart'
    as adapters;
// import 'package:velocambio/models/adapters/custom_model_adapter.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';
import 'package:velocambio/providers/theme_provider.dart';
import 'package:velocambio/widgets/bcv_dialog.dart';
import 'package:velocambio/widgets/bottom_baner_ad.dart';
import 'package:velocambio/widgets/index.dart';

/// Pestaña de inicio.
///
/// Contiene el contenido principal de la app: tasas disponibles,
/// tasa personalizada y la calculadora de conversión.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Future<void> _safeGet(Future<void> Function() fn, String name) async {
    try {
      await fn();
    } catch (e) {
      log('Error: $e', name: name);
    }
  }

  Future<void> getExchangeRate(
    CoinProvider coinProvider,
    UsdExchangeRateProvider exchangeProvider,
    EuroProvider euroProvider,
    BinanceProvider binanceProvider,
    RatesStatsProvider statsProvider,
  ) async {
    //* Provider de tasas de cambio USD
    await _safeGet(() => exchangeProvider.getUsdExchangeRate(), 'USD oficial');
    await _safeGet(() => euroProvider.getEurosExchangeRate(), 'EUR');
    await _safeGet(() => binanceProvider.getBinanceP2pRate(), 'USDT P2P');
    await _safeGet(
      () => exchangeProvider.getUsdMarketExchangeRate(),
      'USD mercado',
    );
    await _safeGet(() => statsProvider.getStats(), 'Brecha y variaciones');

    log('Oficial: ${exchangeProvider.oficialRate}', name: 'HomeTab');
    log('Average: ${exchangeProvider.averageRate}', name: 'HomeTab');
    log('Euro: ${euroProvider.oficialEuroRate}', name: 'HomeTab');
    log('P2P USDT: ${binanceProvider.p2pPrice}', name: 'HomeTab');

    //! Mejorar logica
    //! - Si falla el dolar bcv tomar otra diferente a 0
    //! - cambiar el ExchangeType

    //* Tasa por defecto: BCV oficial; si falla, tomar la primera disponible
    double defaultRate = exchangeProvider.oficialRate;
    ExchangeType defaultType = ExchangeType.oficialUsd;

    if (defaultRate == 0) {
      if (exchangeProvider.averageRate != 0) {
        defaultRate = exchangeProvider.averageRate;
        defaultType = ExchangeType.averageUsd;
      } else if (euroProvider.oficialEuroRate != 0) {
        defaultRate = euroProvider.oficialEuroRate;
        defaultType = ExchangeType.oficialEur;
      } else if (binanceProvider.p2pPrice != 0) {
        defaultRate = binanceProvider.p2pPrice;
        defaultType = ExchangeType.p2pUsdt;
      }
    }

    coinProvider.setAmount(defaultRate);

    //* moneda seleccionada por defecto
    coinProvider.changeExchangeType(defaultType);

    coinProvider.calculatedAmount(
      rateUsdBcv: exchangeProvider.oficialRate,
      rateUsdMarket: exchangeProvider.averageRate,
      rateEUR: euroProvider.oficialEuroRate,
      rateP2P: binanceProvider.p2pPrice,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //* Provider de tasas de cambio USD
      final exchangeProvider = context.read<UsdExchangeRateProvider>();

      //* Provider de tasas de cambio EUR
      final euroProvider = context.read<EuroProvider>();

      //* Provider de historial de Tasas de cambio (BD - SUPABASE)
      final coinProvider = context.read<CoinProvider>();

      //* Provider de Binance P2P
      final binanceProvider = context.read<BinanceProvider>();

      //* Provider de brechas y variaciones
      final statsProvider = context.read<RatesStatsProvider>();

      log('Bienvenido!', name: 'HomeTab');

      await getExchangeRate(
        coinProvider,
        exchangeProvider,
        euroProvider,
        binanceProvider,
        statsProvider,
      );

      //* Dialog de aviso del BCV
      if (!mounted) return;
      BcvDisclaimerModal.show(context);
    });
  }

  //* HIVE
  Future<bool> setHiveCurrencyHistory(
    adapters.CurrencyHistoryModel data,
    CoinProvider provider,
  ) async {
    final response = await provider.insertCurrencyHistory(data);

    if (response == false) {
      log('Error al insertar', name: 'HIVE - HomeTab');
      return false;
    }

    return response;
  }

  ExchangeType selectedType = ExchangeType.oficialUsd;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final coinProvider = context.watch<CoinProvider>();
    final euroProvider = context.watch<EuroProvider>();
    final customProvider = context.watch<CustomProvider>();
    final binanceProvider = context.watch<BinanceProvider>();
    final statsProvider = context.watch<RatesStatsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    void selectedTypeRate(ExchangeType type, double rate, String currencyCode) {
      HapticFeedback.selectionClick();
      coinProvider.changeExchangeType(type);

      if (coinProvider.inputCurrencyCoin != Currency.ves.code) {
        coinProvider.setInputCurrencyCoin(currencyCode);
      } else {
        coinProvider.setOutputCurrencyCoin(currencyCode);
      }

      setState(() => selectedType = type);

      coinProvider.setAmount(rate);

      coinProvider.calculatedAmount(
        rateUsdBcv: exchangeProvider.oficialRate,
        rateUsdMarket: exchangeProvider.averageRate,
        rateEUR: euroProvider.oficialEuroRate,
        rateP2P: binanceProvider.p2pPrice,
      );
    }

    if (coinProvider.exchangeType == ExchangeType.oficialUsd) {
      setState(() => selectedType = ExchangeType.oficialUsd);
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            const BottomBannerAd(),

            //* Titulo, Boton de actualizar y fecha (siempre centrado)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Tasas disponibles',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  Tooltip(
                    message: 'Actualizar tasas',
                    child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: themeProvider.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () => getExchangeRate(
                        coinProvider,
                        exchangeProvider,
                        euroProvider,
                        binanceProvider,
                        statsProvider,
                      ),
                    ),
                  ),

                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () => selectedTypeRate(
                    ExchangeType.oficialUsd,
                    exchangeProvider.oficialRate,
                    Currency.usd.code,
                  ),
                  child: ExchangeRateContainer(
                    imagePath: Currency.usd.flagPath,
                    type: ExchangeType.oficialUsd,
                    size: size.width * 0.9,
                    value: exchangeProvider.oficialRate,
                    nameType: 'BCV Oficial',
                    isSelected: selectedType == ExchangeType.oficialUsd,
                    icon: const Icon(Icons.account_balance),
                    brecha: statsProvider.brechaDe(ExchangeType.oficialUsd),
                    variacion24h: statsProvider.variacion24hDe(
                      ExchangeType.oficialUsd,
                    ),
                    variacion7d: statsProvider.variacion7dDe(
                      ExchangeType.oficialUsd,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => selectedTypeRate(
                    ExchangeType.averageUsd,
                    exchangeProvider.averageRate,
                    Currency.usd.code,
                  ),
                  child: ExchangeRateContainer(
                    imagePath: Currency.usd.flagPath,
                    type: ExchangeType.averageUsd,
                    size: size.width * 0.9,
                    value: exchangeProvider.averageRate,
                    nameType: 'Promedio',
                    isSelected: selectedType == ExchangeType.averageUsd,
                    icon: const Icon(Icons.currency_exchange),
                    brecha: statsProvider.brechaDe(ExchangeType.averageUsd),
                    variacion24h: statsProvider.variacion24hDe(
                      ExchangeType.averageUsd,
                    ),
                    variacion7d: statsProvider.variacion7dDe(
                      ExchangeType.averageUsd,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => selectedTypeRate(
                    ExchangeType.oficialEur,
                    euroProvider.oficialEuroRate,
                    Currency.eur.code,
                  ),
                  child: ExchangeRateContainer(
                    imagePath: Currency.eur.flagPath,
                    type: ExchangeType.oficialEur,
                    size: size.width * 0.9,
                    value: euroProvider.oficialEuroRate,
                    nameType: 'Euro',
                    isSelected: selectedType == ExchangeType.oficialEur,
                    icon: const Icon(Icons.account_balance),
                    brecha: statsProvider.brechaDe(ExchangeType.oficialEur),
                    variacion24h: statsProvider.variacion24hDe(
                      ExchangeType.oficialEur,
                    ),
                    variacion7d: statsProvider.variacion7dDe(
                      ExchangeType.oficialEur,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => selectedTypeRate(
                    ExchangeType.p2pUsdt,
                    binanceProvider.p2pPrice,
                    Currency.usdt.code,
                  ),
                  child: ExchangeRateContainer(
                    imagePath: Currency.usd.flagPath,
                    type: ExchangeType.p2pUsdt,
                    size: size.width * 0.9,
                    value: binanceProvider.p2pPrice,
                    nameType: 'USDT P2P',
                    isSelected: selectedType == ExchangeType.p2pUsdt,
                    icon: const Icon(Icons.currency_bitcoin),
                    brecha: statsProvider.brechaDe(ExchangeType.p2pUsdt),
                    variacion24h: statsProvider.variacion24hDe(
                      ExchangeType.p2pUsdt,
                    ),
                    variacion7d: statsProvider.variacion7dDe(
                      ExchangeType.p2pUsdt,
                    ),
                  ),
                ),
              ],
            ),

            if (customProvider.selectedCustomModel != null) ...[
              GestureDetector(
                onTap: () => selectedTypeRate(
                  ExchangeType.custom,
                  customProvider.selectedCustomModel!.value,
                  Currency.custom.code,
                ),
                child: ExchangeRateContainer(
                  imagePath: Currency.usd.flagPath,
                  type: ExchangeType.custom,
                  size: size.width * 0.9,
                  value: customProvider.selectedCustomModel!.value,
                  nameType: 'Personalizada',
                  isSelected: coinProvider.exchangeType == ExchangeType.custom,
                  icon: const Icon(Icons.edit),
                ),
              ),
            ] else ...[
              // Botón de agregar tasa personalizada (comentado temporalmente)
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 0,
                thickness: 0.5,
                color: primaryColor.withAlpha(20),
              ),
            ),

            //* Calculadora
            const Calculator(),

            const SizedBox(height: 2),

            const BottomBannerAd(),
          ],
        ),
      ),
    );
  }
}
