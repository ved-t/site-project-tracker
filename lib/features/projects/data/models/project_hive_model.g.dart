// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectHiveModelAdapter extends TypeAdapter<ProjectHiveModel> {
  @override
  final int typeId = 1;

  @override
  ProjectHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime?,
      deletedAt: fields[5] as DateTime?,
      deviceId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.deletedAt)
      ..writeByte(6)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
