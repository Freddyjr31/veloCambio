class CurrencyHistoryModel {

  final DateTime createdAt; // timestamp with time zone -> DateTime
  
  // Valores BCV (o base)
  final double? previusValue; // numeric -> double
  final double? value;
  final bool? incrementValue; // boolean -> bool
  final double? percentageDifference;

  // Valores Mercado Paralelo (USD)
  final double? marketUsdPreviusValue;
  final double? marketUsdValue;
  final bool? marketUsdIncrementValue;
  final double? marketUsdPercentageDifference;

  // Valores Euro
  final double? euroPreviusValue;
  final double? euroValue;
  final bool? euroIncrementValue;
  final double? euroPercentageDifference;

  final DateTime? averageRateUpdateDate;
  final DateTime? oficialRateUpdateDate; 


  CurrencyHistoryModel({
    required this.createdAt,
    this.previusValue,
    this.value,
    this.incrementValue,
    this.percentageDifference,
    this.marketUsdPreviusValue,
    this.marketUsdValue,
    this.marketUsdIncrementValue,
    this.marketUsdPercentageDifference,
    this.euroPreviusValue,
    this.euroValue,
    this.euroIncrementValue,
    this.euroPercentageDifference,
    this.oficialRateUpdateDate,
    this.averageRateUpdateDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'previus_value': previusValue,
      'value': value,
      'increment_value': incrementValue,
      'percentage_difference': percentageDifference,
      'market_usd_previus_value': marketUsdPreviusValue,
      'market_usd_value': marketUsdValue,
      'market_usd_increment_value': marketUsdIncrementValue,
      'market_usd_percentage_difference': marketUsdPercentageDifference,
      'euro_previus_value': euroPreviusValue,
      'euro_value': euroValue,
      'euro_increment_value': euroIncrementValue,
      'euro_percentage_difference': euroPercentageDifference,
      'oficial_update_date': oficialRateUpdateDate?.toIso8601String(),
      'average_update_date': averageRateUpdateDate?.toIso8601String(),
    };
  }

  factory CurrencyHistoryModel.fromJson(Map<String, dynamic> json) {
    return CurrencyHistoryModel(
      createdAt: DateTime.parse(json['created_at']),
      previusValue: json['previus_value'],
      value: json['value'],
      incrementValue: json['increment_value'],
      percentageDifference: json['percentage_difference'],
      marketUsdPreviusValue: json['market_usd_previus_value'],
      marketUsdValue: json['market_usd_value'],
      marketUsdIncrementValue: json['market_usd_increment_value'],
      marketUsdPercentageDifference: json['market_usd_percentage_difference'],
      euroPreviusValue: json['euro_previus_value'],
      euroValue: json['euro_value'],
      euroIncrementValue: json['euro_increment_value'],
      euroPercentageDifference: json['euro_percentage_difference'],
      oficialRateUpdateDate: json['oficial_update_date'] != null ? DateTime.parse(json['oficial_update_date']) : null,
      averageRateUpdateDate: json['average_update_date'] != null ? DateTime.parse(json['average_update_date']) : null,
    );
  }
}