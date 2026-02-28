import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_hive_model.g.dart';

@HiveType(typeId: 2)
class ExpenseHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String siteId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String categoryId;

  @HiveField(7)
  final String vendor;

  @HiveField(8)
  final String? remarks;

  @HiveField(9)
  final DateTime? updatedAt;

  @HiveField(10)
  final DateTime? deletedAt;

  @HiveField(11)
  final String deviceId;

  @HiveField(12)
  final bool isPaymentCompleted;

  ExpenseHiveModel({
    required this.id,
    required this.siteId,
    required this.title,
    required this.amount,
    required this.createdAt,
    required this.date,
    required this.categoryId,
    required this.vendor,
    this.isPaymentCompleted = false,
    this.remarks,
    this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });

  factory ExpenseHiveModel.fromEntity(Expense expense) => ExpenseHiveModel(
    id: expense.id,
    siteId: expense.siteId,
    title: expense.title,
    amount: expense.amount,
    createdAt: expense.createdAt,
    date: expense.date,
    categoryId: expense.categoryId,
    vendor: expense.vendor,
    isPaymentCompleted: expense.isPaymentCompleted,
    remarks: expense.remarks,
    updatedAt: expense.updatedAt,
    deletedAt: expense.deletedAt,
    deviceId: expense.deviceId,
  );

  Expense toEntity() => Expense(
    id: id,
    siteId: siteId,
    title: title,
    amount: amount,
    createdAt: createdAt,
    date: date,
    categoryId: categoryId,
    vendor: vendor,
    isPaymentCompleted: isPaymentCompleted,
    remarks: remarks,
    updatedAt: updatedAt ?? createdAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
