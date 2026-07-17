import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:velocambio/providers/custom_provider.dart';
import 'package:velocambio/providers/euro_provider.dart';
import 'package:velocambio/providers/index.dart';

class ExchangeRateContainer extends StatefulWidget {

  final String? imagePath;
  final ExchangeType type;
  final double size;
  final double? value;
  final String nameType;
  final bool upValue;
  final bool isSelected;
  final Icon? icon;
  final double? percentageDifference;
  
  const ExchangeRateContainer({
    required this.imagePath,
    required this.type,
    required this.size,
    required this.value,
    required this.nameType,
    required this.upValue,
    required this.isSelected,
    this.icon = const Icon(Icons.currency_exchange),
    this.percentageDifference = 0 ,
    super.key
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

    return Container(
        width: widget.size,
        height: 60,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.grey[50]?.withAlpha(10) : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: widget.isSelected ? Border.all(color: Colors.white30, width: 1) :  Border.all(color: Colors.white10, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Row(
              children: [

                // Icon(
                //   widget.icon!.icon,
                //   color: widget.isSelected ? Colors.white : Colors.grey[600],
                //   size: 25,
                //   fill: 1.0,
                // ),

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
                    color: widget.isSelected ? Theme.of(context).textTheme.bodyLarge!.color : Colors.grey[600],
                    fontWeight: FontWeight.w900
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
                  // Icon(
                  //   widget.upValue && widget.percentageDifference! > 0 ? Icons.arrow_upward : widget.upValue == false && widget.percentageDifference! > 0 ? Icons.arrow_downward : Icons.remove,
                  //   color: widget.upValue && widget.percentageDifference! > 0 ? Colors.green : widget.upValue == false  && widget.percentageDifference! > 0 ? Colors.red : Colors.grey[600],
                  //   size: 15,
                  //   fill: 1.0,
                  // ),
                  Text(
                    '${widget.value?.toStringAsFixed(3)} VES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected ? Colors.green : Colors.grey[600],
                      ),
                  ),
              
                  if(widget.type == ExchangeType.custom)
                    IconButton(
                      color: widget.isSelected ? Colors.white : Colors.grey[600],
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        widget.isSelected ? Icons.delete : Icons.delete_outline,
                      ),
                      onPressed: () {
                        customProvider.removeCustomModel(customProvider.selectedCustomModel!);
                        customProvider.customAmountController.clear();
                        //* Si la tasa personalizada eliminada es la seleccionada, se selecciona la tasa oficial del BCV
                        coinProvider.setAmount(exchangeProvider.oficialRate);

                        coinProvider.calculatedAmount(
                          rateUsdBcv: exchangeProvider.oficialRate,
                          rateUsdMarket: exchangeProvider.averageRate,
                          rateEUR: euroProvider.oficialEuroRate,
                          rateP2P: binanceProvider.p2pPrice,
                        );
                        coinProvider.changeExchangeType(ExchangeType.oficialUsd);
                      },
                    )
                ],
              ),
            ),

          ],
        ),
      );
  }
}