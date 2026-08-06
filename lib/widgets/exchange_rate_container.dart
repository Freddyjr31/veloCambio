import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:velocambio/core/themes/cmm_theme_data.dart';
import 'package:velocambio/models/exchange_types_model.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';

class ExchangeRateContainer extends StatefulWidget {
  final String? imagePath;
  final ExchangeType type;
  final double size;
  final double? value;
  final String nameType;
  final bool isSelected;
  final Icon? icon;
  final double? percentageDifference;

  const ExchangeRateContainer({
    required this.imagePath,
    required this.type,
    required this.size,
    required this.value,
    required this.nameType,
    required this.isSelected,
    this.icon = const Icon(Icons.currency_exchange),
    this.percentageDifference = 0,
    super.key,
  });

  @override
  State<ExchangeRateContainer> createState() => _ExchangeRateContainerState();
}

class _ExchangeRateContainerState extends State<ExchangeRateContainer> {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final coinProvider = context.watch<CoinProvider>();
    final customProvider = context.watch<CustomProvider>();
    final exchangeProvider = context.watch<UsdExchangeRateProvider>();
    final euroProvider = context.watch<EuroProvider>();
    final binanceProvider = context.watch<BinanceProvider>();

    return SizedBox(
      width: widget.size,
      height: 60,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (widget.isSelected)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.5),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(45),
                      spreadRadius: 13,
                      blurRadius: 12,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
              ),
            ),
          Container(
            width: widget.size,
            height: 60,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? primaryColor.withValues(alpha: 0.05)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(15),
              border: widget.isSelected
                  ? Border.all(color: primaryColor.withAlpha(50), width: 1)
                  : Border.all(color: primaryColor.withAlpha(20), width: 1),
            ),
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
                        color: widget.isSelected
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Colors.grey[600],
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Skeletonizer(
                  enabled: exchangeProvider.isLoading,
                  effect: ShimmerEffect(
                    baseColor: Colors.grey[50]!.withAlpha(50),
                    highlightColor: Colors.grey[50]!.withAlpha(100),
                    duration: Duration(seconds: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.value?.toStringAsFixed(3)} VES',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: widget.isSelected
                                  ? primaryColor
                                  : Colors.grey[600],
                            ),
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
                            coinProvider.setAmount(
                              exchangeProvider.oficialRate,
                            );

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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
