import 'package:hive/hive.dart';

part 'euro_model_adapter.g.dart'; // Este archivo se genera automáticamente

@HiveType(typeId: 3)
class EuroModel extends HiveObject {
  @HiveField(0)
  final String name; // Ejemplo: "BCV Oficial"

  @HiveField(1)
  final double value; // La tasa del día

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime fechaActualizacion;

  EuroModel({
    required this.name,
    required this.value,
    required this.createdAt,
    required this.fechaActualizacion,
  });
}