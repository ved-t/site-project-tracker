// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/expense.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class ExpenseModel with _$ExpenseModel {
  const ExpenseModel._();
  const factory ExpenseModel({
    required String id,
    @JsonKey(name: 'site_id') required String siteId,
    required String title,
    required double amount,
    required DateTime date,
    @JsonKey(name: 'category_id') required String categoryId,
    required String vendor,
    @Default(false)
    @JsonKey(name: 'is_payment_completed')
    bool isPaymentCompleted,
    String? remarks,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @JsonKey(name: 'device_id') required String deviceId,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
    id: e.id,
    siteId: e.siteId,
    title: e.title,
    amount: e.amount,
    date: e.date,
    categoryId: e.categoryId,
    vendor: e.vendor,
    isPaymentCompleted: e.isPaymentCompleted,
    remarks: e.remarks,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    deletedAt: e.deletedAt,
    deviceId: e.deviceId,
  );

  Expense toEntity() => Expense(
    id: id,
    siteId: siteId,
    title: title,
    amount: amount,
    date: date,
    categoryId: categoryId,
    vendor: vendor,
    isPaymentCompleted: isPaymentCompleted,
    remarks: remarks,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
