import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/binance_provider.dart';
import 'package:velocambio/providers/coin_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/exchange_rate_provider.dart';
import 'package:velocambio/providers/theme_provider.dart';

// ignore: must_be_immutable
class InvertCoinButton extends StatefulWidget {
  late CoinProvider coinProvider;
  late UsdExchangeRateProvider exchangeRateProvider;
  late EuroProvider euroProvider;
  late BinanceProvider usdtProvider;
  late Currency destinationCurrency;
  late Currency originCurrency;

  InvertCoinButton({
    super.key,
    required this.coinProvider,
    required this.exchangeRateProvider,
    required this.euroProvider,
    required this.usdtProvider,
    required this.destinationCurrency,
    required this.originCurrency,
  });

  @override
  State<StatefulWidget> createState() => _InvertCoinButtonState();
}

class _InvertCoinButtonState extends State<InvertCoinButton> {
  @override
  Widget build(BuildContext context) {

    var coinProvider = widget.coinProvider;
    var exchangeProvider = widget.exchangeRateProvider;
    var euroProvider = widget.euroProvider;
    var binanceProvider = widget.usdtProvider;
    var destinationCurrency = widget.destinationCurrency;
    var originCurrency = widget.originCurrency;

    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Row(
        spacing: 5,
        children: [

          //* Icono de la moneda de origen
          // Text(
          //   'De: ${coinProvider.inputCurrencyCoin}',
          //   style: Theme.of(context).textTheme.bodyLarge,
          // ),
          RichText(
            text: TextSpan(
              text: 'De: ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              children: [
                TextSpan(
                  text: coinProvider.inputCurrencyCoin,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: themeProvider.isDark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    ),
                ),
              ]
            ),
          ),

          Tooltip(
            message: 'Cambiar monedas',
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: IconButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize: WidgetStateProperty.all(Size(30, 30)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                  backgroundColor: WidgetStateProperty.all(
                    themeProvider.isDark ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () {
                  // setState(() {
                  //   widget.isVes = !widget.isVes;
                  // });

                  //* Intercambiar las monedas
                  coinProvider.changeOriginCurrency(destinationCurrency);
                  coinProvider.changeDestinationCurrency(originCurrency);

                  //* aqui intercambio las tasas de cambio
                  if (!coinProvider.isDestinationVES()) {
                    coinProvider.setInputCurrencyCoin(Currency.ves.code);

                    log(
                      coinProvider.inputCurrencyCoin,
                      name: 'inputCurrencyCoin',
                    );

                    if (ExchangeType.oficialUsd == coinProvider.exchangeType ||
                        ExchangeType.averageUsd == coinProvider.exchangeType) {
                      coinProvider.setOutputCurrencyCoin(Currency.usd.code);
                    } else if (ExchangeType.oficialEur ==
                        coinProvider.exchangeType) {
                      coinProvider.setOutputCurrencyCoin(Currency.eur.code);
                    } else if (ExchangeType.custom ==
                        coinProvider.exchangeType) {
                      coinProvider.setOutputCurrencyCoin(Currency.custom.code);
                    } else if (ExchangeType.p2pUsdt ==
                        coinProvider.exchangeType) {
                      coinProvider.setOutputCurrencyCoin(Currency.usdt.code);
                    }
                  } else {
                    coinProvider.setOutputCurrencyCoin(Currency.ves.code);

                    log(
                      coinProvider.outputCurrencyCoin,
                      name: 'outputCurrencyCoin',
                    );

                    if (ExchangeType.oficialUsd == coinProvider.exchangeType ||
                        ExchangeType.averageUsd == coinProvider.exchangeType) {
                      coinProvider.setInputCurrencyCoin(Currency.usd.code);
                    } else if (ExchangeType.oficialEur ==
                        coinProvider.exchangeType) {
                      coinProvider.setInputCurrencyCoin(Currency.eur.code);
                    } else if (ExchangeType.custom ==
                        coinProvider.exchangeType) {
                      coinProvider.setInputCurrencyCoin(Currency.custom.code);
                    } else if (ExchangeType.p2pUsdt ==
                        coinProvider.exchangeType) {
                      coinProvider.setInputCurrencyCoin(Currency.usdt.code);
                    }
                  }

                  //* Recalcular el monto con la nueva moneda de destino
                  coinProvider.calculatedAmount(
                    rateUsdBcv: exchangeProvider.oficialRate,
                    rateUsdMarket: exchangeProvider.averageRate,
                    rateEUR: euroProvider.oficialEuroRate,
                    rateP2P: binanceProvider.p2pPrice,
                  );
                },
                icon: Icon(
                  Icons.swap_horiz,
                  color: themeProvider.isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),

          //* Icono de la moneda de destino
          // Text(
          //   'A: ${coinProvider.outputCurrencyCoin}',
          //   style: Theme.of(context).textTheme.bodyLarge,
          // ),
          RichText(
            text: TextSpan(
              text: 'A: ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              children: [
                TextSpan(
                  text: coinProvider.outputCurrencyCoin,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
