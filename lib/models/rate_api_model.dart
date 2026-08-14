// ignore_for_file: non_constant_identifier_names

class RateApiResponseModel {
  final double price;
  final String source_type_code;
  final String currency_from_code;
  final String currency_to_code;
  final String rate_type_code;
  final DateTime fetched_at;

  RateApiResponseModel({
    required this.price,
    required this.source_type_code,
    required this.currency_from_code,
    required this.currency_to_code,
    required this.rate_type_code,
    required this.fetched_at,
  });

  //* to json
  Map<String, dynamic> toJson() => {
    'price': price,
    'source_type_code': source_type_code,
    'currency_from_code': currency_from_code,
    'currency_to_code': currency_to_code,
    'rate_type_code': rate_type_code,
    'fetched_at': fetched_at.toIso8601String(),
  };

  //* modelo vacío como fallback
  factory RateApiResponseModel.empty() => RateApiResponseModel(
    price: 0,
    source_type_code: '',
    currency_from_code: '',
    currency_to_code: '',
    rate_type_code: '',
    fetched_at: DateTime.now(),
  );

  //* from json
  factory RateApiResponseModel.fromJson(Map<String, dynamic> json) {
    return RateApiResponseModel(
      price: (json['price'] as num?)?.toDouble() ?? 0,
      source_type_code: json['source_type_code']?.toString() ?? '',
      currency_from_code: json['currency_from_code']?.toString() ?? '',
      currency_to_code: json['currency_to_code']?.toString() ?? '',
      rate_type_code: json['rate_type_code']?.toString() ?? '',
      fetched_at:
          DateTime.tryParse(json['fetched_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
