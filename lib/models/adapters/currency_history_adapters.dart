import 'package:hive/hive.dart';

part 'currency_history_adapters.g.dart';

@HiveType(typeId: 1) // Un ID único para este modelo
class CurrencyHistoryModel extends HiveObject {
  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final double? previusValue;

  @HiveField(2)
  final double? value;

  @HiveField(3)
  final bool? incrementValue;

  @HiveField(4)
  final double? percentageDifference;

  @HiveField(5)
  final double? marketUsdPreviusValue;

  @HiveField(6)
  final double? marketUsdValue;

  @HiveField(7)
  final bool? marketUsdIncrementValue;

  @HiveField(8)
  final double? marketUsdPercentageDifference;

  @HiveField(9)
  final double? euroPreviusValue;

  @HiveField(10)
  final double? euroValue;

  @HiveField(11)
  final bool? euroIncrementValue;

  @HiveField(12)
  final double? euroPercentageDifference;

  @HiveField(13)
  final DateTime? averageRateUpdateDate;

  @HiveField(14)
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

  //* TO JSON
  Map<String, dynamic> toJson() => {
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

  factory CurrencyHistoryModel.fromJson(Map<String, dynamic> json) =>
      CurrencyHistoryModel(
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
        oficialRateUpdateDate: json['oficial_update_date'] != null
            ? DateTime.parse(json['oficial_update_date'])
            : null,
        averageRateUpdateDate: json['average_update_date'] != null
            ? DateTime.parse(json['average_update_date'])
            : null,
      );
}
