import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/features/reports/presentation/controllers/reports_controller.dart';
import 'package:site_project_tracker/features/reports/presentation/widgets/category_pie_chart.dart';
import 'package:site_project_tracker/features/reports/presentation/widgets/spend_bar_chart.dart';
import 'package:site_project_tracker/features/reports/presentation/widgets/summary_cards_row.dart';
import 'package:site_project_tracker/features/reports/presentation/widgets/time_range_selector.dart';
import 'package:site_project_tracker/features/reports/presentation/widgets/top_vendors_list.dart';

class ReportsPage extends StatelessWidget {
  final String siteId;

  const ReportsPage({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportsController>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TimeRangeSelector(
          onChanged: (range) {
            controller.load(siteId, range.start, range.end);
          },
        ),
        const SizedBox(height: 24),
        if (controller.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (controller.errorMessage != null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Error loading report",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          )
        else if (controller.report != null) ...[
          SummaryCardsRow(report: controller.report!),
          const SizedBox(height: 24),
          CategoryPieChart(data: controller.report!.categoryWiseSpent),
          const SizedBox(height: 24),
          SpendBarChart(data: controller.report!.spendOverTime),
          const SizedBox(height: 24),
          TopVendorsList(data: controller.report!.vendorWiseSpent),
        ],
      ],
    );
  }
}
