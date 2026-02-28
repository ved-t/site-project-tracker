import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:site_project_tracker/features/sites/settings/domain/entities/category.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 4)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String siteId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final int color;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  @HiveField(7)
  final DateTime? deletedAt;

  @HiveField(8)
  final String deviceId;

  CategoryHiveModel({
    required this.id,
    required this.siteId,
    required this.name,
    required this.iconCodePoint,
    required this.color,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });

  factory CategoryHiveModel.fromEntity(ExpenseCategoryEntity category) =>
      CategoryHiveModel(
        id: category.id,
        siteId: category.siteId,
        name: category.name,
        iconCodePoint: category.icon.codePoint,
        color: category.color.value,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
        deletedAt: category.deletedAt,
        deviceId: category.deviceId,
      );

  ExpenseCategoryEntity toEntity() => ExpenseCategoryEntity(
    id: id,
    siteId: siteId,
    name: name,
    icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
    color: Color(color),
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
    deviceId: deviceId,
  );
}
