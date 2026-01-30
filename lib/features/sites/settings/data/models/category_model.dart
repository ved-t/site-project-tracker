import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category.dart';

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
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(ExpenseCategoryEntity c) =>
      CategoryModel(
        id: c.id,
        siteId: c.siteId,
        name: c.name,
        iconCodePoint: c.icon.codePoint,
        colorValue: c.color.value,
        createdAt: c.createdAt,
      );

  ExpenseCategoryEntity toEntity() => ExpenseCategoryEntity(
        id: id,
        siteId: siteId,
        name: name,
        icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
        color: Color(colorValue),
        createdAt: createdAt,
      );
}
