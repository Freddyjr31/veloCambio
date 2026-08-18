import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utlis/format_coins.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';
import 'package:velocambio/providers/theme_provider.dart';
import 'package:velocambio/widgets/invert_coin_button.dart';
import 'package:velocambio/widgets/operations_modal.dart';

/// Calculadora personalizada para ingresar montos
class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  ///
  double amount = 0.00;

  ///
  double valueAmount = 0.00;

  /// Para mostrar el monto ingresado en la calculadora
  String calculatorAmount = '';

  /// Para guardar el monto total de la conversión
  String amountCalculated = '';

  /// Para saber si el monto debe reflejarse en VES
  bool isVes = true;

  @override
  Widget build(BuildContext context) {
    final coinProvider = context.watch<CoinProvider>();
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final euroProvider = context.watch<EuroProvider>();
    final binanceProvider = context.watch<BinanceProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    Currency originCurrency = coinProvider.originCurrency; //* USD primera vez
    Currency destinationCurrency =
        coinProvider.destinationCurrency; //* VES primera vez

    /// Para obtener el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    ///* Para mostrar el monto ingresado en la calculadora y demas (solo son logs)
    log(
      formatoBolivar.format(coinProvider.amount).toString(),
      name: 'amount provider Bs',
    );
    log(
      formatoDolar.format(coinProvider.amount).toString(),
      name: 'amount provider USD',
    );
    log(formatoBolivar.format(amount).toString(), name: 'amount Bs');
    log(formatoDolar.format(amount).toString(), name: 'amount USD');

    return Container(
      width: size.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: themeProvider.isDark ? primaryColor.withAlpha(20) : surfaceColor.withAlpha(20), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                child: Text(
                  'Conversión ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              //*  boton para cambiar las monedas
              InvertCoinButton(
                coinProvider: coinProvider,
                exchangeRateProvider: exchangeProvider,
                euroProvider: euroProvider,
                usdtProvider: binanceProvider,
                originCurrency: originCurrency,
                destinationCurrency: destinationCurrency,
              ),
            ],
          ),

          //* Monto Total
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: size.width * 0.65,
                    margin: const EdgeInsets.only(top: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text.rich(
                        TextSpan(
                          text: 'Total: ',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: coinProvider.isDestinationVES()
                                  ? formatoBolivar.format(
                                      coinProvider.currentAmount,
                                    )
                                  : ExchangeType.oficialUsd ==
                                        coinProvider.exchangeType
                                  ? "${formatoDolar.format(coinProvider.currentAmount)} USD"
                                  : ExchangeType.oficialEur ==
                                        coinProvider.exchangeType
                                  ? "${formatoEuro.format(coinProvider.currentAmount)} EUR"
                                  : ExchangeType.p2pUsdt ==
                                        coinProvider.exchangeType
                                  ? "${formatoDolar.format(coinProvider.currentAmount)} USDT"
                                  : destinationCurrency == Currency.usd
                                  ? "${formatoDolar.format(coinProvider.currentAmount)} USD"
                                  : destinationCurrency == Currency.ves
                                  ? formatoBolivar.format(
                                      coinProvider.currentAmount,
                                    )
                                  : "${formatoEuro.format(coinProvider.currentAmount)} EUR",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),

                // const Spacer(),
                SizedBox(
                  width: size.width * 0.1,
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      //* Copiamos el monto
                      Clipboard.setData(
                        ClipboardData(
                          text: coinProvider.isDestinationVES()
                              ? formatoBolivar.format(
                                  coinProvider.currentAmount,
                                )
                              : ExchangeType.oficialUsd ==
                                    coinProvider.exchangeType
                              ? coinProvider.currentAmount.toStringAsFixed(3)
                              : ExchangeType.oficialEur ==
                                    coinProvider.exchangeType
                              ? coinProvider.currentAmount.toStringAsFixed(3)
                              : coinProvider.destinationCurrency == Currency.usd
                              ? coinProvider.currentAmount.toStringAsFixed(3)
                              : coinProvider.destinationCurrency == Currency.ves
                              ? coinProvider.currentAmount.toStringAsFixed(3)
                              : coinProvider.currentAmount.toStringAsFixed(3),
                        ),
                      );

                      //* Para mostrar mensaje de que se ha copiado el monto
                      toastification.show(
                        style: ToastificationStyle.fillColored,
                        title: Text(
                          isVes
                              ? formatoBolivar.format(
                                  coinProvider.currentAmount,
                                )
                              : ExchangeType.oficialUsd ==
                                    coinProvider.exchangeType
                              ? "${formatoDolar.format(coinProvider.currentAmount)} USD"
                              : ExchangeType.oficialEur ==
                                    coinProvider.exchangeType
                              ? "${formatoEuro.format(coinProvider.currentAmount)} EUR"
                              : coinProvider.destinationCurrency == Currency.usd
                              ? "${formatoDolar.format(coinProvider.currentAmount)} USD"
                              : coinProvider.destinationCurrency == Currency.ves
                              ? "${formatoBolivar.format(coinProvider.currentAmount)} VES"
                              : "${formatoEuro.format(coinProvider.currentAmount)} EUR",
                        ),
                        description: Text('Monto copiado al portapapeles!'),
                        type: ToastificationType.success,
                        autoCloseDuration: Duration(seconds: 3),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          //* Input de monto
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    // color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black45,
                    //     blurRadius: 5,
                    //     offset: Offset(0, 3),
                    //   )
                    // ]
                  ),
                  child: TextField(
                    onTapUpOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: coinProvider.amountController,
                    onChanged: (value) {
                      setState(() {
                        amount = coinProvider.calculatedAmount(
                          rateUsdBcv: exchangeProvider.oficialRate,
                          rateUsdMarket: exchangeProvider.averageRate,
                          rateEUR: euroProvider.oficialEuroRate,
                          rateP2P: binanceProvider.p2pPrice,
                        );
                      });
                    },
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Theme.of(context).brightness,
                    textAlign: TextAlign.end,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(
                        Icons.currency_exchange,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      label: Text(
                        'Monto a cambiar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      prefix: Text(
                        coinProvider.inputCurrencyCoin,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      suffixStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          coinProvider.amountController.clear();
                          coinProvider.calculatedAmount(
                            rateUsdBcv: exchangeProvider.oficialRate,
                            rateUsdMarket: exchangeProvider.averageRate,
                            rateEUR: euroProvider.oficialEuroRate,
                            rateP2P: binanceProvider.p2pPrice,
                          );
                          setState(() {
                            amount = 0.00;
                          });
                        },
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1),

          //*  boton para abrir el modal de operaciones (%, sumar/restar)
          Tooltip(
            message: 'Operaciones sobre el resultado',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  OperationsModal.show(
                    context,
                    baseAmount: coinProvider.currentAmount,
                    currencyCode: coinProvider.outputCurrencyCoin,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: primaryColor.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerLow,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.percent),
                    SizedBox(width: 5),
                    Text(
                      'Operaciones',
                      style: ThemeData().textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: primaryColor
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
