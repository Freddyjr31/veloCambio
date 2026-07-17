class BinanceP2PModel {
  final double bestPrice;
  final DateTime updatedAt;
  final List<BinanceAdModel> ads;

  BinanceP2PModel({
    required this.bestPrice,
    required this.updatedAt,
    required this.ads,
  });
}

class BinanceAdModel {
  final double price;
  final String traderName;
  final List<String> paymentMethods;
  final double minAmount;
  final double maxAmount;
  final double surplusAmount;
  final int monthOrderCount;
  final double monthFinishRate;

  BinanceAdModel({
    required this.price,
    required this.traderName,
    required this.paymentMethods,
    required this.minAmount,
    required this.maxAmount,
    required this.surplusAmount,
    required this.monthOrderCount,
    required this.monthFinishRate,
  });

  factory BinanceAdModel.fromJson(Map<String, dynamic> json) {
    final adv = json['adv'] as Map<String, dynamic>? ?? {};
    final advertiser = json['advertiser'] as Map<String, dynamic>?;

    return BinanceAdModel(
      price: double.tryParse(adv['price']?.toString() ?? '0') ?? 0,
      traderName: advertiser?['nickName'] ?? '',
      paymentMethods: (adv['tradeMethods'] as List?)
              ?.map((m) =>
                  (m as Map<String, dynamic>)['tradeMethodName']?.toString() ??
                  '')
              .toList() ??
          [],
      minAmount: double.tryParse(
              adv['minSingleTransAmount']?.toString() ?? '0') ??
          0,
      maxAmount: double.tryParse(
              adv['maxSingleTransAmount']?.toString() ?? '0') ??
          0,
      surplusAmount:
          double.tryParse(adv['surplusAmount']?.toString() ?? '0') ?? 0,
      monthOrderCount: advertiser?['monthFinishOrderCount'] ?? 0,
      monthFinishRate:
          (advertiser?['monthFinishRate'] ?? 0.0).toDouble(),
    );
  }
}
