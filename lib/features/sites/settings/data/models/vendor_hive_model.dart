import 'package:hive/hive.dart';
import 'package:site_project_tracker/features/sites/settings/domain/entities/vendor.dart';

part 'vendor_hive_model.g.dart';

@HiveType(typeId: 3)
class VendorHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String siteId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  @HiveField(7)
  final DateTime? deletedAt;

  @HiveField(8)
  final String deviceId;

  VendorHiveModel({
    required this.id,
    required this.siteId,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });

  factory VendorHiveModel.fromEntity(Vendor vendor) => VendorHiveModel(
    id: vendor.id,
    siteId: vendor.siteId,
    name: vendor.name,
    phone: vendor.phone,
    notes: vendor.notes,
    createdAt: vendor.createdAt,
    updatedAt: vendor.updatedAt,
    deletedAt: vendor.deletedAt,
    deviceId: vendor.deviceId,
  );

  Vendor toEntity() => Vendor(
    id: id,
    siteId: siteId,
    name: name,
    phone: phone,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
