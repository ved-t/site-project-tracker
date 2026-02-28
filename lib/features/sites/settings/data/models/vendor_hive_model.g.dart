// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VendorHiveModelAdapter extends TypeAdapter<VendorHiveModel> {
  @override
  final int typeId = 3;

  @override
  VendorHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VendorHiveModel(
      id: fields[0] as String,
      siteId: fields[1] as String,
      name: fields[2] as String,
      phone: fields[3] as String?,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
      deletedAt: fields[7] as DateTime?,
      deviceId: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VendorHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.deletedAt)
      ..writeByte(8)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
