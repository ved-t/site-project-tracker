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
    required String category,
    required String vendor,
    String? remarks,
    required DateTime createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
    id: e.id,
    siteId: e.siteId,
    title: e.title,
    amount: e.amount,
    date: e.date,
    category: e.category,
    vendor: e.vendor,
    remarks: e.remarks,
    createdAt: e.createdAt,
  );

  Expense toEntity() => Expense(
    id: id,
    siteId: siteId,
    title: title,
    amount: amount,
    date: date,
    category: category,
    vendor: vendor,
    remarks: remarks,
    createdAt: createdAt,
  );
}
