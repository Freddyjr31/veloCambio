import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/core/utlis/format_coins.dart';
import 'package:velocambio/models/currency_model.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/models/multi_item_model.dart';
import 'package:velocambio/providers/coin_provider.dart';
import 'package:velocambio/providers/multi_items_provider.dart';
import 'package:velocambio/providers/theme_provider.dart';
import 'package:velocambio/widgets/bottom_baner_ad.dart';

/// Pestaña de multi-items.
///
/// Permite evaluar varios montos en simultáneo usando la tasa seleccionada
/// en la calculadora principal (tasa global), editable por cada item.
class MultiItemsTab extends StatelessWidget {
  const MultiItemsTab({super.key});

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
    final multiProvider = context.watch<MultiItemsProvider>();
    final coinProvider = context.watch<CoinProvider>();
    final themeProvider = context.watch<ThemeProvider>();

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
                  'Multi-items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Evalúa varios montos a la vez con la tasa '
                  '$baseCurrency seleccionada',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          //* Lista de items (o estado vacio)
          Expanded(
            child: multiProvider.items.isEmpty
                ? _EmptyItemsState(baseCurrency: baseCurrency)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: multiProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = multiProvider.items[index];
                      return _MultiItemCard(
                        key: ValueKey(item.id),
                        item: item,
                        index: index,
                        globalRate: globalRate,
                        baseCurrency: baseCurrency,
                      );
                    },
                  ),
          ),

          //* Boton agregar item (compacto, a la derecha)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    //* Nuevo item hereda la tasa global de la calculadora.
                    multiProvider
                      ..setDefaultRate(globalRate)
                      ..addItem();
                  },
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: themeProvider.isDark ? Colors.white : Colors.black,
                  ),
                  label: Text(
                    'Agregar item',
                    style: TextStyle(
                      color: themeProvider.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withAlpha(60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: primaryColor.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),

          //* Total
          _TotalCard(total: multiProvider.totalFor(globalRate)),

          const SizedBox(height: 84),
        ],
      ),
    );
  }
}

/// Estado vacío cuando aún no hay items.
class _EmptyItemsState extends StatelessWidget {
  final String baseCurrency;

  const _EmptyItemsState({required this.baseCurrency});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Icon(Icons.playlist_add, size: 56, color: Colors.grey[600]),
          Text(
            'No hay items aún',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Agrega montos en $baseCurrency y observa su valor en VES',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un item individual (monto + tasa + resultado).
class _MultiItemCard extends StatelessWidget {
  final MultiItem item;
  final int index;
  final double globalRate;
  final String baseCurrency;

  const _MultiItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.globalRate,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final multiProvider = context.read<MultiItemsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    //* Tasa efectiva: la global o la cotización propia del item.
    final effectiveRate = item.useGlobalRate
        ? globalRate
        : (item.customRate ?? 0);
    final result = item.resultFor(globalRate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: themeProvider.isDark
              ? primaryColor.withAlpha(20)
              : surfaceColor.withAlpha(20),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          //* Monto base + boton eliminar
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  keyboardAppearance: Theme.of(context).brightness,
                  textAlign: TextAlign.end,
                  onChanged: (value) {
                    multiProvider.updateAmount(
                      index,
                      double.tryParse(value.replaceAll(',', '.')) ?? 0,
                    );
                  },
                  decoration: InputDecoration(
                    filled: true,
                    prefix: Text(
                      '$baseCurrency ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    label: const Text('Monto'),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                tooltip: 'Eliminar item',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => multiProvider.removeItem(index),
              ),
            ],
          ),

          const SizedBox(height: 8),

          //* Tasa (global editable por item)
          Row(
            children: [
              Expanded(
                child: item.useGlobalRate
                    //* Muestra la tasa global; al tocarla pasa a editable.
                    ? InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => multiProvider.useCustomRate(
                          index,
                          globalRate: globalRate,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryColor.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '${truncateTo(effectiveRate, 3).toStringAsFixed(3)} VES',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: primaryColor),
                                ),
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  const Icon(Icons.link, size: 14),
                                  Text(
                                    'Toca para editar',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    //* Tasa propia editable.
                    : TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        keyboardAppearance: Theme.of(context).brightness,
                        textAlign: TextAlign.end,
                        onChanged: (value) {
                          multiProvider.updateRate(
                            index,
                            double.tryParse(value.replaceAll(',', '.')) ?? 0,
                          );
                        },
                        decoration: InputDecoration(
                          filled: true,
                          prefix: Text(
                            'Tasa ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          label: const Text('VES'),
                        ),
                      ),
              ),

              const SizedBox(width: 8),

              //* Restaurar tasa global del item
              IconButton(
                tooltip: 'Usar tasa global',
                icon: const Icon(Icons.sync),
                onPressed: () => multiProvider.restoreGlobalRate(index),
              ),
            ],
          ),

          const SizedBox(height: 8),

          //* Resultado del item
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Resultado', style: Theme.of(context).textTheme.bodySmall),
              Flexible(
                child: Text(
                  formatBolivarTrunc(result),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con el total de todos los items.
class _TotalCard extends StatelessWidget {
  final double total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: Theme.of(context).textTheme.titleMedium),
          Flexible(
            child: Text(
              formatBolivarTrunc(total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
