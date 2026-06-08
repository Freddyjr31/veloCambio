// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_history_adapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyHistoryModelAdapter extends TypeAdapter<CurrencyHistoryModel> {
  @override
  final int typeId = 1;

  @override
  CurrencyHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyHistoryModel(
      createdAt: fields[0] as DateTime,
      previusValue: fields[1] as double?,
      value: fields[2] as double?,
      incrementValue: fields[3] as bool?,
      percentageDifference: fields[4] as double?,
      marketUsdPreviusValue: fields[5] as double?,
      marketUsdValue: fields[6] as double?,
      marketUsdIncrementValue: fields[7] as bool?,
      marketUsdPercentageDifference: fields[8] as double?,
      euroPreviusValue: fields[9] as double?,
      euroValue: fields[10] as double?,
      euroIncrementValue: fields[11] as bool?,
      euroPercentageDifference: fields[12] as double?,
      oficialRateUpdateDate: fields[14] as DateTime?,
      averageRateUpdateDate: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyHistoryModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.previusValue)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.incrementValue)
      ..writeByte(4)
      ..write(obj.percentageDifference)
      ..writeByte(5)
      ..write(obj.marketUsdPreviusValue)
      ..writeByte(6)
      ..write(obj.marketUsdValue)
      ..writeByte(7)
      ..write(obj.marketUsdIncrementValue)
      ..writeByte(8)
      ..write(obj.marketUsdPercentageDifference)
      ..writeByte(9)
      ..write(obj.euroPreviusValue)
      ..writeByte(10)
      ..write(obj.euroValue)
      ..writeByte(11)
      ..write(obj.euroIncrementValue)
      ..writeByte(12)
      ..write(obj.euroPercentageDifference)
      ..writeByte(13)
      ..write(obj.averageRateUpdateDate)
      ..writeByte(14)
      ..write(obj.oficialRateUpdateDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
