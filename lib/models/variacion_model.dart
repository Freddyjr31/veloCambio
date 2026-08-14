// ignore_for_file: non_constant_identifier_names

class VariacionesResponseModel {
  final RateVariacionModel usdOficial;
  final RateVariacionModel usdParalelo;
  final RateVariacionModel eur;
  final RateVariacionModel usdt;

  VariacionesResponseModel({
    required this.usdOficial,
    required this.usdParalelo,
    required this.eur,
    required this.usdt,
  });

  factory VariacionesResponseModel.empty() => VariacionesResponseModel(
    usdOficial: RateVariacionModel.empty(),
    usdParalelo: RateVariacionModel.empty(),
    eur: RateVariacionModel.empty(),
    usdt: RateVariacionModel.empty(),
  );

  factory VariacionesResponseModel.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>? ?? {};
    return VariacionesResponseModel(
      usdOficial: RateVariacionModel.fromJson(
        rates['usd_oficial'] as Map<String, dynamic>? ?? {},
      ),
      usdParalelo: RateVariacionModel.fromJson(
        rates['usd_paralelo'] as Map<String, dynamic>? ?? {},
      ),
      eur: RateVariacionModel.fromJson(
        rates['eur'] as Map<String, dynamic>? ?? {},
      ),
      usdt: RateVariacionModel.fromJson(
        rates['usdt'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class RateVariacionModel {
  final double price;
  final double variacion24h;
  final double variacion7d;
  final DateTime fetchedAt;

  RateVariacionModel({
    required this.price,
    required this.variacion24h,
    required this.variacion7d,
    required this.fetchedAt,
  });

  factory RateVariacionModel.empty() => RateVariacionModel(
    price: 0,
    variacion24h: 0,
    variacion7d: 0,
    fetchedAt: DateTime.now(),
  );

  factory RateVariacionModel.fromJson(Map<String, dynamic> json) =>
      RateVariacionModel(
        price: (json['price'] as num?)?.toDouble() ?? 0,
        variacion24h: (json['variacion_24h'] as num?)?.toDouble() ?? 0,
        variacion7d: (json['variacion_7d'] as num?)?.toDouble() ?? 0,
        fetchedAt:
            DateTime.tryParse(json['fetched_at']?.toString() ?? '') ??
            DateTime.now(),
      );
}
