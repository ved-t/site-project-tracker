import 'package:flutter/material.dart';
import '../../expenses/presentation/screens/expense_list_screen.dart';

class SiteExpensesTab extends StatelessWidget {
  final String siteId;

  const SiteExpensesTab({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return ExpenseListScreen(siteId: siteId);
  }
}
