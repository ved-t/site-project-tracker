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
      category: fields[6] as String,
      vendor: fields[7] as String,
      remarks: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseHiveModel obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.vendor)
      ..writeByte(8)
      ..write(obj.remarks);
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
