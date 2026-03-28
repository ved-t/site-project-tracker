import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/report_section.dart';
import '../../domain/enums/chart_type.dart';
import '../../domain/enums/report_metric.dart';
import '../../data/services/report_engine.dart';

class ReportSectionWidget extends StatefulWidget {
  final ReportSection config;
  final List<dynamic> expenses;
  final VoidCallback? onDelete;

  const ReportSectionWidget({
    super.key,
    required this.config,
    required this.expenses,
    this.onDelete,
  });

  @override
  State<ReportSectionWidget> createState() => _ReportSectionWidgetState();
}

class _ReportSectionWidgetState extends State<ReportSectionWidget> {
  DateTimeRange? _dateRange;

  String get _title {
    switch (widget.config.metric) {
      case ReportMetric.cashOutflow:
        final g = widget.config.granularity?.name ?? 'monthly';
        return 'Cash Outflow (${g[0].toUpperCase()}${g.substring(1)})';
      case ReportMetric.spendByCategory:
        return 'Spend by Category';
      case ReportMetric.spendByVendor:
        return 'Spend by Vendor';
      case ReportMetric.vendorLeaderboard:
        return 'Vendor Leaderboard';
    }
  }

  List<dynamic> get _filteredExpenses {
    var list = widget.expenses;
    if (widget.config.enableDateFilter && _dateRange != null) {
      list = list.where((e) {
        final d = e.date as DateTime;
        return !d.isBefore(_dateRange!.start) &&
            !d.isAfter(
                _dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    return list;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange ??
          DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expenses = _filteredExpenses;
    final data = ReportEngine.generate(expenses, widget.config);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(
                  _iconForMetric(widget.config.metric),
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.config.enableDateFilter)
                  TextButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(LucideIcons.calendar, size: 14),
                    label: Text(
                      _dateRange == null
                          ? 'Filter Date'
                          : '${DateFormat('dd MMM').format(_dateRange!.start)} – ${DateFormat('dd MMM').format(_dateRange!.end)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  onPressed: widget.onDelete,
                  color: colorScheme.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildChartBadge(context),
            const SizedBox(height: 16),
            _buildChart(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeLabel = widget.config.chartType == ChartType.line
        ? 'Line Graph'
        : widget.config.chartType == ChartType.pie
            ? 'Pie Chart'
            : 'Horizontal Bar';

    return Wrap(
      spacing: 6,
      children: [
        Chip(
          label: Text(badgeLabel, style: const TextStyle(fontSize: 10)),
          padding: EdgeInsets.zero,
          labelPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: -4),
          backgroundColor: colorScheme.primaryContainer,
          labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
        if (widget.config.enablePaidUnpaid)
          Chip(
            label:
                const Text('Paid vs Unpaid', style: TextStyle(fontSize: 10)),
            padding: EdgeInsets.zero,
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: -4),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
          ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, Map<String, dynamic> data) {
    switch (widget.config.chartType) {
      case ChartType.line:
        return _buildLineOrBarChart(context, data);
      case ChartType.pie:
        return _buildPieChart(context, data);
      case ChartType.horizontalBar:
        return _buildLeaderboard(context, data);
    }
  }

  /// Renders a real bar chart using fl_chart
  Widget _buildLineOrBarChart(
      BuildContext context, Map<String, dynamic> rawData) {
    Map<String, double> paidData = {};
    Map<String, double> unpaidData = {};

    if (widget.config.enablePaidUnpaid && rawData.containsKey('paid')) {
      paidData = Map<String, double>.from(rawData['paid'] as Map);
      unpaidData = Map<String, double>.from(rawData['unpaid'] as Map);
    } else {
      paidData = Map<String, double>.from(rawData);
    }

    final allKeys = {
      ...paidData.keys,
      ...unpaidData.keys,
    }.toList()
      ..sort();

    if (allKeys.isEmpty) {
      return _emptyState(context);
    }

    final maxVal = allKeys.fold<double>(0, (max, key) {
      final total = (paidData[key] ?? 0) + (unpaidData[key] ?? 0);
      return total > max ? total : max;
    });

    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.compactCurrency(
        symbol: '₹', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final key = allKeys[group.x];
                      final paid = paidData[key] ?? 0;
                      final unpaid = unpaidData[key] ?? 0;
                      final total = paid + unpaid;
                      return BarTooltipItem(
                        '$key\n',
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Total: ${currencyFormat.format(total)}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.config.enablePaidUnpaid) ...[
                            TextSpan(
                              text: '\nPaid: ${currencyFormat.format(paid)}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: '\nUnpaid: ${currencyFormat.format(unpaid)}',
                              style: TextStyle(
                                color: colorScheme.primary.withValues(alpha: 0.5),
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= allKeys.length) return const SizedBox.shrink();
                        final key = allKeys[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            key.length > 7 ? key.substring(key.length - 4) : key,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 10,
                                ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max) return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 10,
                              ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? (maxVal / 4 == 0 ? 1 : maxVal / 4) : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: allKeys.asMap().entries.map((entry) {
                  final x = entry.key;
                  final key = entry.value;
                  final paid = paidData[key] ?? 0;
                  final unpaid = unpaidData[key] ?? 0;

                  return BarChartGroupData(
                    x: x,
                    barRods: [
                      BarChartRodData(
                        toY: paid + unpaid,
                        width: 20,
                        borderRadius: widget.config.enablePaidUnpaid && unpaid > 0
                            ? const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))
                            : BorderRadius.circular(4),
                        color: widget.config.enablePaidUnpaid ? Colors.transparent : colorScheme.primary,
                        rodStackItems: widget.config.enablePaidUnpaid
                            ? [
                                BarChartRodStackItem(
                                    0, paid, colorScheme.primary),
                                BarChartRodStackItem(paid, paid + unpaid,
                                    colorScheme.primary.withValues(alpha: 0.3)),
                              ]
                            : null,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (widget.config.enablePaidUnpaid) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(colorScheme.primary, 'Paid'),
              const SizedBox(width: 16),
              _legendDot(colorScheme.primary.withValues(alpha: 0.3), 'Unpaid'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  /// Renders a real pie chart using fl_chart
  Widget _buildPieChart(BuildContext context, Map<String, dynamic> rawData) {
    Map<String, double> data = {};

    if (widget.config.enablePaidUnpaid && rawData.containsKey('paid')) {
      final paid = Map<String, double>.from(rawData['paid'] as Map);
      final unpaid = Map<String, double>.from(rawData['unpaid'] as Map);
      for (final k in {...paid.keys, ...unpaid.keys}) {
        data[k] = (paid[k] ?? 0) + (unpaid[k] ?? 0);
      }
    } else {
      data = Map<String, double>.from(rawData);
    }

    if (data.isEmpty) return _emptyState(context);

    final total = data.values.fold<double>(0, (s, v) => s + v);
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = _paletteColors(context);
    final currencyFormat =
        NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final pct = total > 0 ? (e.value / total * 100) : 0.0;
                final color = colors[i % colors.length];

                return PieChartSectionData(
                  color: color,
                  value: e.value,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final color = colors[i % colors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.key} (${currencyFormat.format(e.value)})',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Renders vendor leaderboard as a ranked list with horizontal bars
  Widget _buildLeaderboard(
      BuildContext context, Map<String, dynamic> rawData) {
    List<MapEntry<String, double>> entries = [];

    if (rawData.containsKey('entries')) {
      // VendorLeaderboardCalculator returns List<MapEntry<String, double>>
      final raw = rawData['entries'] as List<MapEntry<String, double>>;
      entries = raw;
    } else {
      // flat map format (fallback)
      final flat = Map<String, double>.from(rawData);
      entries = flat.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      entries = entries.take(10).toList();
    }

    if (entries.isEmpty) return _emptyState(context);

    final maxVal =
        entries.isEmpty ? 0.0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final currencyFormat =
        NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: entries.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final e = entry.value;
        final ratio = maxVal > 0 ? e.value / maxVal : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '#$rank',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: rank <= 3
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: Text(
                  e.key,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: LinearProgressIndicator(
                  value: ratio,
                   backgroundColor:
                       colorScheme.primary.withValues(alpha: 0.1),
                  color: rank == 1
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.5 + ratio * 0.4),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(e.value),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No data available',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ),
    );
  }

  IconData _iconForMetric(ReportMetric m) {
    switch (m) {
      case ReportMetric.cashOutflow:
        return LucideIcons.trendingUp;
      case ReportMetric.spendByCategory:
        return LucideIcons.pieChart;
      case ReportMetric.spendByVendor:
        return LucideIcons.store;
      case ReportMetric.vendorLeaderboard:
        return LucideIcons.trophy;
    }
  }

  List<Color> _paletteColors(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];
  }
}