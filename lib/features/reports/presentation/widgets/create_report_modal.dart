import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/report_section.dart';
import '../../domain/enums/chart_type.dart';
import '../../domain/enums/report_metric.dart';
import '../../domain/enums/granularity.dart';

class CreateReportModal extends StatefulWidget {
  final String siteId;
  const CreateReportModal({super.key, required this.siteId});

  @override
  State<CreateReportModal> createState() => _CreateReportModalState();
}

class _CreateReportModalState extends State<CreateReportModal> {
  ChartType? chartType;
  ReportMetric? metric;
  Granularity? granularity;
  bool enableDateFilter = false;
  bool enablePaidUnpaid = false;

  /// Only metrics valid for chosen chart type
  List<ReportMetric> get _allowedMetrics {
    switch (chartType) {
      case ChartType.line:
        return [ReportMetric.cashOutflow];
      case ChartType.pie:
        return [ReportMetric.spendByCategory, ReportMetric.spendByVendor];
      case ChartType.horizontalBar:
        return [ReportMetric.vendorLeaderboard];
      case null:
        return ReportMetric.values;
    }
  }

  bool get _showGranularity =>
      chartType == ChartType.line && metric == ReportMetric.cashOutflow;

  bool get _canSubmit {
    if (chartType == null || metric == null) return false;
    if (_showGranularity && granularity == null) return false;
    return true;
  }

  void _onChartTypeChanged(ChartType? v) {
    setState(() {
      chartType = v;
      metric = null; // reset metric when chart type changes
      granularity = null;
    });
  }

  void submit() {
    if (!_canSubmit) return;

    final section = ReportSection(
      id: const Uuid().v4(),
      siteId: widget.siteId,
      chartType: chartType!,
      metric: metric!,
      granularity: granularity,
      enableDateFilter: enableDateFilter,
      enablePaidUnpaid: enablePaidUnpaid,
    );

    Navigator.pop(context, section);
  }

  String _chartTypeLabel(ChartType t) {
    switch (t) {
      case ChartType.line:
        return 'Line Graph (Cash Outflow)';
      case ChartType.pie:
        return 'Pie Chart (Spend Distribution)';
      case ChartType.horizontalBar:
        return 'Horizontal Bar (Vendor Leaderboard)';
    }
  }

  String _metricLabel(ReportMetric m) {
    switch (m) {
      case ReportMetric.cashOutflow:
        return 'Monthly / Weekly / Daily Cash Outflow';
      case ReportMetric.spendByCategory:
        return 'Spend by Category';
      case ReportMetric.spendByVendor:
        return 'Spend by Vendor';
      case ReportMetric.vendorLeaderboard:
        return 'Vendor Leaderboard (Top 10)';
    }
  }

  String _granularityLabel(Granularity g) {
    switch (g) {
      case Granularity.daily:
        return 'Daily';
      case Granularity.weekly:
        return 'Weekly';
      case Granularity.monthly:
        return 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Create Report Section',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a chart type and configure what to display.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Step 1: Chart Type
          Text(
            'Chart Type',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ChartType>(
            isExpanded: true,
            value: chartType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select chart type',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: ChartType.values.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  _chartTypeLabel(e),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _onChartTypeChanged,
          ),

          // Step 2: Metric (shown only when chart type selected)
          if (chartType != null) ...[
            const SizedBox(height: 16),
            Text(
              'Metric',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReportMetric>(
              isExpanded: true,
              value: metric,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select metric',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: _allowedMetrics.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    _metricLabel(e),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => metric = v),
            ),
          ],

          // Step 3: Granularity (only for Line chart with cashOutflow)
          if (_showGranularity) ...[
            const SizedBox(height: 16),
            Text(
              'Granularity',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Granularity>(
              isExpanded: true,
              value: granularity,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select time grouping',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: Granularity.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    _granularityLabel(e),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => granularity = v),
            ),
          ],

          if (metric != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Options',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            // Date Filter toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Date Filter'),
              subtitle: const Text('Filter data by a date range'),
              value: enableDateFilter,
              onChanged: (v) => setState(() => enableDateFilter = v),
            ),

            // Paid vs Unpaid toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid vs Unpaid'),
              subtitle: const Text(
                  'Show stacked chart with paid/unpaid breakdown'),
              value: enablePaidUnpaid,
              onChanged: (v) => setState(() => enablePaidUnpaid = v),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canSubmit ? submit : null,
              icon: const Icon(Icons.add_chart),
              label: const Text('Add to Report'),
            ),
          ),
        ],
      ),
    );
  }
}