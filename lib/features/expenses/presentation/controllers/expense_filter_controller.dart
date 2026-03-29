import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense.dart';
import 'expense_controller.dart';

class ExpenseFilter {
  final List<String>? categories;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? minDate;
  final DateTime? maxDate;

  const ExpenseFilter({
    this.categories,
    this.minAmount,
    this.maxAmount,
    this.minDate,
    this.maxDate,
  });

  ExpenseFilter copyWith({
    List<String>? categories,
    double? minAmount,
    double? maxAmount,
    DateTime? minDate,
    DateTime? maxDate,
    bool clearMin = false,
    bool clearMax = false,
    bool clearMinDate = false,
    bool clearMaxDate = false,
  }) {
    return ExpenseFilter(
      categories: categories ?? this.categories,
      minAmount: clearMin ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMax ? null : (maxAmount ?? this.maxAmount),
      minDate: clearMinDate ? null : (minDate ?? this.minDate),
      maxDate: clearMaxDate ? null : (maxDate ?? this.maxDate),
    );
  }

  bool get isEmpty =>
      (categories == null || categories!.isEmpty) &&
      minAmount == null &&
      maxAmount == null &&
      minDate == null &&
      maxDate == null;
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

        // Min date filter (start of day)
        if (filter.minDate != null) {
          final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
          final minD = DateTime(filter.minDate!.year, filter.minDate!.month, filter.minDate!.day);
          if (expDate.isBefore(minD)) return false;
        }

        // Max date filter (start of day)
        if (filter.maxDate != null) {
          final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
          final maxD = DateTime(filter.maxDate!.year, filter.maxDate!.month, filter.maxDate!.day);
          if (expDate.isAfter(maxD)) return false;
        }

        return true;
      }).toList();
    });
