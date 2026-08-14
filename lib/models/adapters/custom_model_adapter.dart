import 'package:hive/hive.dart';

part 'custom_model_adapter.g.dart'; // Este archivo se genera automáticamente

@HiveType(typeId: 2)
class CustomModel extends HiveObject {
  @HiveField(0)
  final String name; // Ejemplo: "BCV Oficial"

  @HiveField(1)
  final double value; // La tasa del día

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime fechaActualizacion;

  CustomModel({
    required this.name,
    required this.value,
    required this.createdAt,
    required this.fechaActualizacion,
  });

  // Mantén tus métodos de JSON aquí mismo
  factory CustomModel.fromJson(Map<String, dynamic> json) {
    return CustomModel(
      name: json['name'],
      value: (json['value'] as num).toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'createdAt': createdAt.toIso8601String(),
    'fechaActualizacion': fechaActualizacion.toIso8601String(),
  };
}
