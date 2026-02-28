import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_ds.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource local;

  ExpenseRepositoryImpl(this.local);

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      final models = await local.getAll();
      return models.map((e) => e.toEntity()).toList();
    } catch (e) {
      // Handle error or throw
      rethrow;
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await local.saveExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await local.saveExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) async {
    await local.deleteExpenses([id]);
  }

  @override
  Future<List<Expense>> getExpensesBySite(String siteId) async {
    final models = await local.getExpensesBySite(siteId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteExpensesBySite(String siteId) async {
    final models = await local.getExpensesBySite(siteId);

    final keysToDelete = models
        .where((e) => e.siteId == siteId)
        .map((e) => e.id)
        .toList();

    await local.deleteExpenses(keysToDelete);
  }

  @override
  Future<List<Expense>> getLocalChanges(DateTime? since) async {
    final models = await local.getLocalChanges(since);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> applyRemoteChanges(List<Expense> changes) async {
    final models = changes.map((e) => ExpenseModel.fromEntity(e)).toList();
    await local.applyRemoteChanges(models);
  }
}
