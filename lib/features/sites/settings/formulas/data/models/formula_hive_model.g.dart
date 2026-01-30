// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formula_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormulaHiveModelAdapter extends TypeAdapter<FormulaHiveModel> {
  @override
  final int typeId = 5;

  @override
  FormulaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormulaHiveModel(
      id: fields[0] as String,
      siteId: fields[1] as String,
      name: fields[2] as String,
      expression: fields[3] as String,
      variables: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FormulaHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.expression)
      ..writeByte(4)
      ..write(obj.variables)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormulaHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
