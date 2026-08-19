import 'package:hive/hive.dart';

part 'cached_rate_adapter.g.dart';

@HiveType(typeId: 6)
class CachedRateModel extends HiveObject {
  @HiveField(0)
  final double price;

  @HiveField(1)
  final String rateTypeCode;

  @HiveField(2)
  final DateTime fetchedAt;

  CachedRateModel({
    required this.price,
    required this.rateTypeCode,
    required this.fetchedAt,
  });
}
