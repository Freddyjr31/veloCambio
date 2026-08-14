class EuroExchangeModel {
  final List<EuroExchangeTypeModel> exchange;

  EuroExchangeModel({required this.exchange});

  factory EuroExchangeModel.fromList(List list) {
    return EuroExchangeModel(
      exchange: list.map((e) => EuroExchangeTypeModel.fromJson(e)).toList(),
    );
  }
}

class EuroExchangeTypeModel {
  final String? moneda;
  final String? fuente;
  final String? nombre;
  final double? compra;
  final double? venta;
  final double promedio;
  final DateTime? fechaActualizacion;
  final DateTime? fecha;

  EuroExchangeTypeModel({
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
  factory EuroExchangeTypeModel.fromJson(Map<String, dynamic> json) {
    return EuroExchangeTypeModel(
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
