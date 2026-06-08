// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usd_market_model_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsdMarketModelAdapter extends TypeAdapter<UsdMarketModel> {
  @override
  final int typeId = 5;

  @override
  UsdMarketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsdMarketModel(
      name: fields[0] as String,
      value: fields[1] as double,
      createdAt: fields[2] as DateTime,
      fechaActualizacion: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UsdMarketModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.fechaActualizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsdMarketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
