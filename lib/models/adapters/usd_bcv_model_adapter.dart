import 'package:hive/hive.dart';

part 'usd_bcv_model_adapter.g.dart'; // Este archivo se genera automáticamente

@HiveType(typeId: 4)
class UsdBcvModel extends HiveObject {
  @HiveField(0)
  final String name; // Ejemplo: "BCV Oficial"

  @HiveField(1)
  final double value; // La tasa del día

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime fechaActualizacion;

  UsdBcvModel({
    required this.name,
    required this.value,
    required this.createdAt,
    required this.fechaActualizacion,
  });
}
