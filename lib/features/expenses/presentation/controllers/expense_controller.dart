import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:site_project_tracker/core/services/sync_manager.dart';
import '../../../../core/utils/dio_error_handler.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../../core/utils/logger.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_project.dart';
import '../../domain/usecases/update_expense.dart';

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
        ref.read(syncManagerProvider),
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
  final SyncManager _syncManager;

  ExpenseController(
    this._getExpenses,
    this._addExpense,
    this._updateExpense,
    this._deleteExpense,
    this._syncManager,
  ) : super([]) {
    load();
  }

  List<Expense> get expenses => state;

  Future<void> load() async {
    try {
      state = await _getExpenses();
    } catch (e) {
      AppLogger.error(
        'Failed to load expenses',
        error: e,
        name: 'EXPENSE_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _addExpense(expense);
      await load();
      // Sync in background
      _syncManager.sync().then((success) {
        if (success) {
          ToastUtils.show('Synced with server');
        }
      });
    } catch (e) {
      AppLogger.error('Failed to add expense', error: e, name: 'EXPENSE_CTRL');
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _updateExpense(expense);
      await load();
      _syncManager.sync().then((success) {
        if (success) {
          ToastUtils.show('Synced with server');
        }
      });
    } catch (e) {
      AppLogger.error(
        'Failed to update expense',
        error: e,
        name: 'EXPENSE_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _deleteExpense(id);
      await load();
      _syncManager.sync().then((success) {
        if (success) {
          ToastUtils.show('Synced with server');
        }
      });
    } catch (e) {
      AppLogger.error(
        'Failed to delete expense',
        error: e,
        name: 'EXPENSE_CTRL',
      );
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }
}
