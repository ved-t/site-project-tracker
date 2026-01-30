import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/expenses/presentation/widgets/add_expense_sheet.dart';
import 'package:site_project_tracker/features/expenses/presentation/widgets/filter_bottom_sheet.dart';
import '../controllers/expense_filter_controller.dart';
import '../widgets/expense_row.dart';
import '../widgets/expense_summary_card.dart';
import '../../../../../core/utils/dialog_utils.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/widgets/site_header.dart';
import '../../../../../core/widgets/bouncing_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpenseListScreen extends ConsumerWidget {
  final String siteId;
  const ExpenseListScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the FILTERED expenses
    final expensesAsync = ref.watch(filteredProjectExpensesProvider(siteId));
    final filter = ref.watch(expenseFilterProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: expensesAsync.when(
          data: (expenses) {
            final totalAmount = expenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );

            // Group items by date
            final Map<String, List<Expense>> groupedExpenses = {};
            for (var expense in expenses) {
              final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
              groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
            }
            final sortedDates = groupedExpenses.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SiteHeader(
                        title: 'Expense Ledger',
                        trailing: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.filter),
                              onPressed: () {
                                showAnimatedDialog(
                                  context,
                                  Dialog(
                                    insetPadding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: SingleChildScrollView(
                                      child: FilterBottomSheet(siteId: siteId),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (!filter.isEmpty)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 8,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ExpenseSummaryCard(
                        totalAmount: totalAmount,
                        totalEntries: expenses.length,
                      ),
                      if (!filter.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.info,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Showing filtered results',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blue),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  ref
                                          .read(expenseFilterProvider.notifier)
                                          .state =
                                      const ExpenseFilter();
                                },
                                child: const Text(
                                  'Clear Filters',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                if (expenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filter.isEmpty
                                ? 'No expenses added yet'
                                : 'No results matching filters',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...sortedDates.expand((dateKey) {
                    final dateExpenses = groupedExpenses[dateKey]!;
                    final date = DateTime.parse(dateKey);
                    final isToday =
                        dateKey ==
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 8,
                            left: 4,
                          ),
                          child: Text(
                            isToday
                                ? 'TODAY'
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(date).toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Colors.grey[500],
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              ExpenseRow(expense: dateExpenses[index]),
                          childCount: dateExpenses.length,
                        ),
                      ),
                    ];
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),

      /// Floating Action Button
      floatingActionButton: BouncingButton(
        child: FloatingActionButton.extended(
          onPressed: () {
            showAnimatedDialog(
              context,
              Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: AddExpenseSheet(siteId: siteId),
                ),
              ),
            );
          },
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Expense'),
        ),
      ),
    );
  }
}
