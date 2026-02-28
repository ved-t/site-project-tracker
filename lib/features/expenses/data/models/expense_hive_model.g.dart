// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseHiveModelAdapter extends TypeAdapter<ExpenseHiveModel> {
  @override
  final int typeId = 2;

  @override
  ExpenseHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseHiveModel(
      id: fields[0] as String,
      siteId: fields[1] as String,
      title: fields[2] as String,
      amount: fields[3] as double,
      createdAt: fields[4] as DateTime,
      date: fields[5] as DateTime,
      categoryId: fields[6] as String,
      vendor: fields[7] as String,
      isPaymentCompleted: fields[12] as bool,
      remarks: fields[8] as String?,
      updatedAt: fields[9] as DateTime?,
      deletedAt: fields[10] as DateTime?,
      deviceId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.vendor)
      ..writeByte(8)
      ..write(obj.remarks)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.deletedAt)
      ..writeByte(11)
      ..write(obj.deviceId)
      ..writeByte(12)
      ..write(obj.isPaymentCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
