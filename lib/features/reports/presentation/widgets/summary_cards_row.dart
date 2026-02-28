import 'package:flutter/material.dart';
import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';

class SummaryCardsRow extends StatelessWidget {
  final SiteReport report;

  const SummaryCardsRow({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card("Total Spend", report.totalAmountSpent),
        _card("Today", report.todayExpense),
        _card("Avg / Day", report.avgExpensePerDay),
      ],
    );
  }

  Widget _card(String title, double value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title),
              const SizedBox(height: 8),
              Text(
                "₹${value.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
