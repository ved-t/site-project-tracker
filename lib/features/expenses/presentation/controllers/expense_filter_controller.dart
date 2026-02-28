import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense.dart';
import 'expense_controller.dart';

class ExpenseFilter {
  final List<String>? categories;
  final double? minAmount;
  final double? maxAmount;

  const ExpenseFilter({this.categories, this.minAmount, this.maxAmount});

  ExpenseFilter copyWith({
    List<String>? categories,
    double? minAmount,
    double? maxAmount,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return ExpenseFilter(
      categories: categories ?? this.categories,
      minAmount: clearMin ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMax ? null : (maxAmount ?? this.maxAmount),
    );
  }

  bool get isEmpty =>
      (categories == null || categories!.isEmpty) &&
      minAmount == null &&
      maxAmount == null;
}

final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) {
  return const ExpenseFilter();
});

final filteredProjectExpensesProvider =
    FutureProvider.family<List<Expense>, String>((ref, siteId) async {
      final expensesAsync = await ref.watch(
        projectExpensesProvider(siteId).future,
      );
      final filter = ref.watch(expenseFilterProvider);

      if (filter.isEmpty) return expensesAsync;

      return expensesAsync.where((expense) {
        // Category filter
        if (filter.categories != null &&
            filter.categories!.isNotEmpty &&
            !filter.categories!.contains(expense.categoryId)) {
          return false;
        }

        // Min amount filter
        if (filter.minAmount != null && expense.amount < filter.minAmount!) {
          return false;
        }

        // Max amount filter
        if (filter.maxAmount != null && expense.amount > filter.maxAmount!) {
          return false;
        }

        return true;
      }).toList();
    });
