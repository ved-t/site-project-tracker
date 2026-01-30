import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<List<Expense>> getExpensesBySite(String siteId);
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);

  // Affected by Site Deletion
  Future<void> deleteExpensesBySite(String siteId);
}
