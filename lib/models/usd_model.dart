class UsdExchangeModel {
  final List<UsdExchangeTypeModel> exchange;

  UsdExchangeModel({required this.exchange});

  //* TO JSON
  Map<String, dynamic> toJson() {
    return {'exchange': exchange.map((e) => e.toJson()).toList()};
  }

  //* FROM JSON
  // factory UsdExchangeModel.fromJson(Map<String, dynamic> json) {
  //   return UsdExchangeModel(
  //     exchange: (json['exchange'] as List).map((e) => UsdExchangeTypeModel.fromJson(e)).toList(),
  //   );
  // }

  factory UsdExchangeModel.fromList(List list) {
    return UsdExchangeModel(
      exchange: list.map((e) => UsdExchangeTypeModel.fromJson(e)).toList(),
    );
  }
}

class UsdExchangeTypeModel {
  final String? moneda;
  final String? fuente;
  final String? nombre;
  final double? compra;
  final double? venta;
  final double promedio;
  final DateTime? fechaActualizacion;
  final DateTime? fecha;

  UsdExchangeTypeModel({
    this.moneda,
    this.fuente,
    this.nombre,
    this.compra,
    this.venta,
    required this.promedio,
    this.fechaActualizacion,
    this.fecha,
  });

  //* TO JSON
  Map<String, dynamic> toJson() {
    return {
      'moneda': moneda,
      'fuente': fuente,
      'nombre': nombre,
      'compra': compra,
      'venta': venta,
      'promedio': promedio,
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'fecha': fecha?.toIso8601String(),
    };
  }

  //* FROM JSON
  factory UsdExchangeTypeModel.fromJson(Map<String, dynamic> json) {
    return UsdExchangeTypeModel(
      moneda: json['moneda'] ?? '',
      fuente: json['fuente'] ?? '',
      nombre: json['nombre'] ?? '',
      compra: json['compra'] ?? 0.0,
      venta: json['venta'] ?? 0.0,
      promedio: json['promedio'],
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'])
          : DateTime.now(),
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
    );
  }
}
