import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/coin_provider.dart';
import 'package:velocambio/widgets/bottom_baner_ad.dart';
import 'package:velocambio/widgets/cuotas_calculator.dart';
import 'package:velocambio/widgets/sueldo_calculator.dart';

/// Pestaña de herramientas.
///
/// Agrupa calculadoras financieras (cuotas estilo Cashea y sueldo/quincena)
/// que usan la tasa seleccionada en la calculadora principal.
class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  /// Moneda base según el tipo de tasa seleccionado en la calculadora.
  String _baseCurrencyFor(ExchangeType type) {
    switch (type) {
      case ExchangeType.oficialUsd:
      case ExchangeType.averageUsd:
        return Currency.usd.code;
      case ExchangeType.oficialEur:
        return Currency.eur.code;
      case ExchangeType.p2pUsdt:
        return Currency.usdt.code;
      case ExchangeType.custom:
        return Currency.custom.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = context.watch<CoinProvider>();

    //* Tasa global = tasa seleccionada en la calculadora principal.
    final globalRate = coinProvider.amount;
    final baseCurrency = _baseCurrencyFor(coinProvider.exchangeType);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          //* Banner de ads
          const BottomBannerAd(),

          //* Titulo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              spacing: 4,
              children: [
                Text(
                  'Herramientas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cuotas y sueldos con la tasa '
                  '${truncateTo(globalRate, 3).toStringAsFixed(3)} VES '
                  '($baseCurrency) seleccionada',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          //* Calculadoras
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
              children: [
                CuotasCalculator(rate: globalRate, baseCurrency: baseCurrency),
                const SizedBox(height: 8),
                SueldoCalculator(rate: globalRate, baseCurrency: baseCurrency),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
