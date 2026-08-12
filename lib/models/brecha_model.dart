
// ignore_for_file: non_constant_identifier_names

class BrechaResponseModel {
  final double usdOficialPrice;
  final DateTime usdOficialFetchedAt;
  final BrechaModel usdParalelo;
  final BrechaModel eur;
  final BrechaModel usdt;

  BrechaResponseModel({
    required this.usdOficialPrice,
    required this.usdOficialFetchedAt,
    required this.usdParalelo,
    required this.eur,
    required this.usdt,
  });

  factory BrechaResponseModel.empty() => BrechaResponseModel(
        usdOficialPrice: 0,
        usdOficialFetchedAt: DateTime.now(),
        usdParalelo: BrechaModel.empty(),
        eur: BrechaModel.empty(),
        usdt: BrechaModel.empty(),
      );

  factory BrechaResponseModel.fromJson(Map<String, dynamic> json) {
    final brechas = json['brechas'] as Map<String, dynamic>? ?? {};
    return BrechaResponseModel(
      usdOficialPrice: (json['usd_oficial_price'] as num?)?.toDouble() ?? 0,
      usdOficialFetchedAt:
          DateTime.tryParse(json['usd_oficial_fetched_at']?.toString() ?? '') ??
              DateTime.now(),
      usdParalelo: BrechaModel.fromJson(
        brechas['usd_paralelo'] as Map<String, dynamic>? ?? {},
      ),
      eur: BrechaModel.fromJson(brechas['eur'] as Map<String, dynamic>? ?? {}),
      usdt: BrechaModel.fromJson(brechas['usdt'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class BrechaModel {
  final double rate;
  final double brecha;

  BrechaModel({required this.rate, required this.brecha});

  factory BrechaModel.empty() => BrechaModel(rate: 0, brecha: 0);

  factory BrechaModel.fromJson(Map<String, dynamic> json) => BrechaModel(
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        brecha: (json['brecha'] as num?)?.toDouble() ?? 0,
      );
}
