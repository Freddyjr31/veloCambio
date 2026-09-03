import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/core/utils/truncate.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';
import 'package:velocambio/providers/theme_provider.dart';

class ExchangeRateContainer extends StatefulWidget {
  final String? imagePath;
  final ExchangeType type;
  final double size;
  final double? value;
  final String nameType;
  final bool isSelected;
  final Icon? icon;
  final double? brecha;
  final double? variacion24h;
  final double? variacion7d;

  const ExchangeRateContainer({
    required this.imagePath,
    required this.type,
    required this.size,
    required this.value,
    required this.nameType,
    required this.isSelected,
    this.icon = const Icon(Icons.currency_exchange),
    this.brecha = 0,
    this.variacion24h = 0,
    this.variacion7d = 0,
    super.key,
  });

  @override
  State<ExchangeRateContainer> createState() => _ExchangeRateContainerState();
}

class _ExchangeRateContainerState extends State<ExchangeRateContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectController;

  @override
  void initState() {
    super.initState();
    _selectController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ExchangeRateContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _selectController.forward(from: 0.0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _selectController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final coinProvider = context.watch<CoinProvider>();
    final customProvider = context.watch<CustomProvider>();
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final euroProvider = context.watch<EuroProvider>();
    final binanceProvider = context.watch<BinanceProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return SizedBox(
      height: widget.size / 5.2,
      width: widget.size,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          FadeTransition(
            opacity: _selectController,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.5),
                  // boxShadow: [
                  //   BoxShadow(
                  //     // color: primaryColor.withAlpha(20),
                  //     spreadRadius: 12,
                  //     blurRadius: 12,
                  //     offset: const Offset(2, 5),
                  //   ),
                  // ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _selectController,
            builder: (context, child) {
              final bgColor = Color.lerp(
                themeProvider.isDark
                    ? surfaceColor
                    : Theme.of(context).colorScheme.surfaceContainer,
                themeProvider.isDark
                    ? Colors.black.withAlpha(50)
                    : Theme.of(context).colorScheme.onSurface,
                _selectController.value,
              );
              // final borderColor = Color.lerp(
              //   !themeProvider.isDark
              //       ? surfaceColor.withAlpha(20)
              //       : primaryColor.withAlpha(20),
              //   !themeProvider.isDark
              //       ? surfaceColor
              //       : primaryColor.withAlpha(50),
              //   _selectController.value,
              // );
              return Container(
                width: widget.size,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(15),
                  //border: Border.all(color: borderColor!, width: 0),
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.asset(
                        widget.imagePath!,
                        width: 23,
                        height: 15,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag, size: 15),
                      ),
                    ),

                    SizedBox(width: 10),

                    //* Text
                    Text(
                      widget.nameType,
                      style: TextStyle(
                        // color: widget.isSelected
                        //     ? Theme.of(context).textTheme.bodyLarge!.color
                        //     : Colors.grey[600],
                        color: widget.isSelected ?
                          themeProvider.isDark
                              ? Colors.white
                              : Colors.white
                          : Colors.grey[600],
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Skeletonizer(
                          enabled: exchangeProvider.isLoading,
                          effect: ShimmerEffect(
                            baseColor: themeProvider.isDark
                                ? Colors.grey[50]!.withAlpha(50)
                                : primaryColor.withAlpha(20),
                            highlightColor: themeProvider.isDark
                                ? Colors.grey[50]!.withAlpha(100)
                                : primaryColor.withAlpha(20),
                            duration: Duration(seconds: 1),
                          ),
                          child: Text(
                            '${truncateTo(widget.value ?? 0, 3).toStringAsFixed(3)} VES',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: widget.size / 24,
                                  color: widget.isSelected
                                      ? primaryColor
                                      : Colors.grey[600],
                                ),
                          ),
                        ),

                        if (widget.type != ExchangeType.oficialUsd &&
                            widget.type != ExchangeType.custom)
                          Skeletonizer(
                            enabled: exchangeProvider.isLoading,
                            effect: ShimmerEffect(
                              baseColor: themeProvider.isDark
                                  ? Colors.grey[50]!.withAlpha(50)
                                  : primaryColor.withAlpha(20),
                              highlightColor: themeProvider.isDark
                                  ? Colors.grey[50]!.withAlpha(100)
                                  : primaryColor.withAlpha(20),
                              duration: Duration(seconds: 1),
                            ),
                            child: Text(
                              widget.brecha != null && widget.brecha != 0
                                  ? 'Brecha: ${widget.brecha?.toStringAsFixed(2)}%'
                                  : '',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: widget.size / 36,
                                    color: !widget.isSelected
                                        ? themeProvider.isDark
                                            ? Colors.grey[50]!.withAlpha(100)
                                            : Colors.grey[600]
                                        : Colors.grey[100],
                                  ),
                            ),
                          ),

                        if (widget.type != ExchangeType.custom)
                          Skeletonizer(
                            enabled: exchangeProvider.isLoading,
                            effect: ShimmerEffect(
                              baseColor: themeProvider.isDark
                                  ? Colors.grey[50]!.withAlpha(50)
                                  : primaryColor.withAlpha(20),
                              highlightColor: themeProvider.isDark
                                  ? Colors.grey[50]!.withAlpha(100)
                                  : primaryColor.withAlpha(20),
                              duration: Duration(seconds: 1),
                            ),
                            child: Text(
                              (widget.variacion24h != null ||
                                      widget.variacion7d != null)
                                  ? '24 hr: ${widget.variacion24h?.toStringAsFixed(2)}% | 7d: ${widget.variacion7d?.toStringAsFixed(2)}%'
                                  : '',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: widget.size / 36,
                                    color: !widget.isSelected
                                        ? themeProvider.isDark
                                            ? Colors.grey[50]!.withAlpha(100)
                                            : Colors.grey[800]
                                        : Colors.grey[50],
                                  ),
                            ),
                          ),
                      ],
                    ),

                    if (widget.type == ExchangeType.custom)
                      IconButton(
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.grey[600],
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          widget.isSelected
                              ? Icons.delete
                              : Icons.delete_outline,
                        ),
                        onPressed: () {
                          customProvider.removeCustomModel(
                            customProvider.selectedCustomModel!,
                          );
                          customProvider.customAmountController.clear();

                          //* Si la tasa personalizada eliminada es la seleccionada, se selecciona la tasa oficial del BCV
                          coinProvider.setAmount(exchangeProvider.oficialRate);

                          coinProvider.calculatedAmount(
                            rateUsdBcv: exchangeProvider.oficialRate,
                            rateUsdMarket: exchangeProvider.averageRate,
                            rateEUR: euroProvider.oficialEuroRate,
                            rateP2P: binanceProvider.p2pPrice,
                          );

                          coinProvider.changeExchangeType(
                            ExchangeType.oficialUsd,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
