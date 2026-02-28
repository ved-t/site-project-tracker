import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/interactive_card.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../sites/settings/domain/entities/category.dart';
import '../../../sites/settings/presentation/controllers/category_controller.dart';

class RecentExpensesSection extends StatelessWidget {
  final List<Expense> expenses;

  const RecentExpensesSection({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SizedBox();

    final recentExpenses = expenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: recentExpenses
              .map((e) => _RecentExpenseItem(expense: e))
              .toList(),
        ),
      ],
    );
  }
}

class _RecentExpenseItem extends ConsumerWidget {
  final Expense expense;

  const _RecentExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider(expense.siteId));
    final category = categories.isEmpty
        ? ExpenseCategoryEntity(
            id: 'placeholder',
            siteId: expense.siteId,
            name: expense.categoryId,
            icon: Icons.details,
            color: Colors.grey,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deviceId: 'placeholder',
          )
        : categories.firstWhere(
            (c) => c.id == expense.categoryId,
            orElse: () => categories.firstWhere(
              (c) => c.name == expense.categoryId,
              orElse: () => categories.first,
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InteractiveCard(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        onTap: () {
          context.go('/expenses/${expense.siteId}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 18, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (expense.vendor.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.vendor,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '₹${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
