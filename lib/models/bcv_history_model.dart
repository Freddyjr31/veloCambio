// ignore_for_file: non_constant_identifier_names

/// Registro individual del histórico de tasas BCV
/// (elemento del arreglo `history` de la respuesta).
class BcvHistoryItem {
  final DateTime fecha;
  final double price;
  final double? rate_buy;
  final double? rate_sell;

  BcvHistoryItem({
    required this.fecha,
    required this.price,
    this.rate_buy,
    this.rate_sell,
  });

  //* from json
  factory BcvHistoryItem.fromJson(Map<String, dynamic> json) {
    return BcvHistoryItem(
      fecha:
          DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rate_buy: (json['rate_buy'] as num?)?.toDouble(),
      rate_sell: (json['rate_sell'] as num?)?.toDouble(),
    );
  }
}

/// Respuesta paginada del endpoint `GET /rates/historico/bcv`.
class BcvHistoryResponseModel {
  final String currency;
  final String rate_type;
  final String source;
  final int page;
  final int page_size;
  final int total;
  final int total_pages;
  final List<BcvHistoryItem> history;

  BcvHistoryResponseModel({
    required this.currency,
    required this.rate_type,
    required this.source,
    required this.page,
    required this.page_size,
    required this.total,
    required this.total_pages,
    required this.history,
  });

  //* from json
  factory BcvHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final rawHistory = (json['history'] as List<dynamic>?) ?? [];

    return BcvHistoryResponseModel(
      currency: json['currency']?.toString() ?? '',
      rate_type: json['rate_type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      page: (json['page'] as num?)?.toInt() ?? 0,
      page_size: (json['page_size'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      total_pages: (json['total_pages'] as num?)?.toInt() ?? 0,
      history: rawHistory
          .whereType<Map<String, dynamic>>()
          .map(BcvHistoryItem.fromJson)
          .toList(),
    );
  }
}
