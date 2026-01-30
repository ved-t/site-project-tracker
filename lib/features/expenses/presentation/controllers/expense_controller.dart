import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/expenses/domain/repositories/expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../data/datasources/expense_local_ds.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_project.dart';
import '../../domain/usecases/update_expense.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepositoryImpl(ExpenseLocalDataSource()),
);

final getExpensesProvider = Provider(
  (ref) => GetExpenses(ref.read(expenseRepositoryProvider)),
);

final addExpenseProvider = Provider(
  (ref) => AddExpense(ref.read(expenseRepositoryProvider)),
);

final updateExpenseProvider = Provider(
  (ref) => UpdateExpense(ref.read(expenseRepositoryProvider)),
);

final deleteExpenseProvider = Provider(
  (ref) => DeleteExpense(ref.read(expenseRepositoryProvider)),
);

final getExpensesBySiteProvider = Provider(
  (ref) => GetExpensesByProject(ref.read(expenseRepositoryProvider)),
);

final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, List<Expense>>((ref) {
      return ExpenseController(
        ref.read(getExpensesProvider),
        ref.read(addExpenseProvider),
        ref.read(updateExpenseProvider),
        ref.read(deleteExpenseProvider),
      );
    });

final projectExpensesProvider = FutureProvider.family<List<Expense>, String>((
  ref,
  siteId,
) async {
  final getExpensesBySite = ref.read(getExpensesBySiteProvider);
  return getExpensesBySite(siteId);
});

class ExpenseController extends StateNotifier<List<Expense>> {
  final GetExpenses _getExpenses;
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;

  ExpenseController(
    this._getExpenses,
    this._addExpense,
    this._updateExpense,
    this._deleteExpense,
  ) : super([]) {
    load();
  }

  List<Expense> get expenses => state;

  Future<void> load() async {
    state = await _getExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    await _addExpense(expense);
    await load();
  }

  Future<void> updateExpense(Expense expense) async {
    await _updateExpense(expense);
    await load();
  }

  Future<void> deleteExpense(String id) async {
    await _deleteExpense(id);
    await load();
  }
}
