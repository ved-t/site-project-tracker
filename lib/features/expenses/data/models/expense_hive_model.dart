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
  final String category;

  @HiveField(7)
  final String vendor;

  @HiveField(8)
  final String? remarks;

  ExpenseHiveModel({
    required this.id,
    required this.siteId,
    required this.title,
    required this.amount,
    required this.createdAt,
    required this.date,
    required this.category,
    required this.vendor,
    this.remarks,
  });

  factory ExpenseHiveModel.fromEntity(Expense expense) => ExpenseHiveModel(
    id: expense.id,
    siteId: expense.siteId,
    title: expense.title,
    amount: expense.amount,
    createdAt: expense.createdAt,
    date: expense.date,
    category: expense.category,
    vendor: expense.vendor,
    remarks: expense.remarks,
  );

  Expense toEntity() => Expense(
    id: id,
    siteId: siteId,
    title: title,
    amount: amount,
    createdAt: createdAt,
    date: date,
    category: category,
    vendor: vendor,
    remarks: remarks,
  );
}
