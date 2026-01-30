import 'package:flutter/material.dart';
import '../../../../../core/widgets/interactive_card.dart';

class QuickAddExpenseCard extends StatelessWidget {
  const QuickAddExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveCard(
      onTap: () {
        // TODO: Quick Add Expense Sheet (later)
      },
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.add_circle_outline),
            SizedBox(width: 12),
            Text(
              'Add Quick Expense',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
