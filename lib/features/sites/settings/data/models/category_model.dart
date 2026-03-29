import 'package:flutter/material.dart';
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';
import '../../../../../core/utils/icon_utils.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const CategoryModel._();
  const factory CategoryModel({
    required String id,
    required String siteId,
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @JsonKey(name: 'device_id') required String deviceId,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(ExpenseCategoryEntity c) => CategoryModel(
    id: c.id,
    siteId: c.siteId,
    name: c.name,
    iconCodePoint: c.icon.codePoint,
    colorValue: c.color.value,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
    deletedAt: c.deletedAt,
    deviceId: c.deviceId,
  );

  ExpenseCategoryEntity toEntity() => ExpenseCategoryEntity(
    id: id,
    siteId: siteId,
    name: name,
    icon: IconUtils.getIconFromCodePoint(iconCodePoint),
    color: Color(colorValue),
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
