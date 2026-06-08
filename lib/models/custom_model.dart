class CustomModel {
  final String name;
  final double value;
  final DateTime fechaActualizacion;

  CustomModel({
    required this.name,
    required this.value,
    required this.fechaActualizacion,
  });

  factory CustomModel.fromJson(Map<String, dynamic> json) {
    return CustomModel(
      name: json['name'],
      value: json['value'],
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'fechaActualizacion': fechaActualizacion.toIso8601String(),
  };
}