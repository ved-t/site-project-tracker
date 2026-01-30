import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../../sites/settings/presentation/controllers/category_controller.dart';
import '../../../sites/settings/domain/entities/category.dart';
import '../../../../core/widgets/interactive_card.dart';

class ExpenseRow extends ConsumerWidget {
  final Expense expense;

  const ExpenseRow({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Look up category to get icon and color
    final categories = ref.watch(categoriesProvider(expense.siteId));
    final category = categories.isEmpty
        ? ExpenseCategoryEntity(
            id: 'placeholder',
            siteId: expense.siteId,
            name: expense.category,
            icon: Icons.help_outline,
            color: Colors.grey,
            createdAt: DateTime.now(),
          )
        : categories.firstWhere(
            (c) => c.name == expense.category,
            orElse: () => categories.first,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InteractiveCard(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              /// Category Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 20, color: category.color),
              ),
              const SizedBox(width: 14),

              /// Description & Date
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            expense.title,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(expense.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              /// Amount
              Expanded(
                flex: 2,
                child: Text(
                  '₹${expense.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
