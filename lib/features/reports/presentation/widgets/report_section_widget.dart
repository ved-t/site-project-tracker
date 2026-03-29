import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/report_section.dart';
import '../../domain/enums/chart_type.dart';
import '../../domain/enums/report_metric.dart';
import '../../data/services/report_engine.dart';
import '../../../../features/sites/settings/domain/entities/category.dart';

class ReportSectionWidget extends StatefulWidget {
  final ReportSection config;
  final List<dynamic> expenses;
  final List<ExpenseCategoryEntity>? categories;
  final VoidCallback? onDelete;

  const ReportSectionWidget({
    super.key,
    required this.config,
    required this.expenses,
    this.categories,
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
            !d.isAfter(_dateRange!.end.add(const Duration(days: 1)));
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
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expenses = _filteredExpenses;
    final data = ReportEngine.generate(expenses, widget.config);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored accent strip at the top
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForMetric(widget.config.metric),
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (widget.config.enableDateFilter)
                      _buildDateFilterButton(context),
                    const SizedBox(width: 4),
                    _buildDeleteButton(context),
                  ],
                ),
                const SizedBox(height: 12),
                _buildChartBadge(context),
                const SizedBox(height: 16),
                // Chart area with its own background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: _buildChart(context, data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _pickDateRange,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.calendar, size: 13, color: colorScheme.primary),
              const SizedBox(width: 5),
              Text(
                _dateRange == null
                    ? 'Filter'
                    : '${DateFormat('dd MMM').format(_dateRange!.start)} – ${DateFormat('dd MMM').format(_dateRange!.end)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.onDelete,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            LucideIcons.trash2,
            size: 15,
            color: colorScheme.error.withValues(alpha: 0.7),
          ),
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

    final IconData badgeIcon = widget.config.chartType == ChartType.line
        ? LucideIcons.lineChart
        : widget.config.chartType == ChartType.pie
        ? LucideIcons.pieChart
        : LucideIcons.barChart3;

    return Wrap(
      spacing: 8,
      children: [
        _styledBadge(
          icon: badgeIcon,
          label: badgeLabel,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: colorScheme.primary,
        ),
        if (widget.config.enablePaidUnpaid)
          _styledBadge(
            icon: LucideIcons.splitSquareVertical,
            label: 'Paid vs Unpaid',
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
            foregroundColor: colorScheme.secondary,
          ),
      ],
    );
  }

  Widget _styledBadge({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
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
    BuildContext context,
    Map<String, dynamic> rawData,
  ) {
    Map<String, double> paidData = {};
    Map<String, double> unpaidData = {};

    if (widget.config.enablePaidUnpaid && rawData.containsKey('paid')) {
      paidData = Map<String, double>.from(rawData['paid'] as Map);
      unpaidData = Map<String, double>.from(rawData['unpaid'] as Map);
    } else {
      paidData = Map<String, double>.from(rawData);
    }

    final allKeys = {...paidData.keys, ...unpaidData.keys}.toList()..sort();

    if (allKeys.isEmpty) {
      return _emptyState(context);
    }

    final maxVal = allKeys.fold<double>(0, (max, key) {
      final total = (paidData[key] ?? 0) + (unpaidData[key] ?? 0);
      return total > max ? total : max;
    });

    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.compactCurrency(
      symbol: '₹',
      decimalDigits: 0,
    );

    // Dynamic bar width based on number of entries so they don't overlap
    final int entryCount = allKeys.isEmpty ? 1 : allKeys.length;
    double barWidth = 12.0;
    double barsSpace = 4.0;
    if (entryCount > 15) {
      barWidth = 4.0;
      barsSpace = 1.0;
    } else if (entryCount > 7) {
      barWidth = 8.0;
      barsSpace = 2.0;
    }

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
                    getTooltipColor: (group) =>
                        colorScheme.surfaceContainerHighest,
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
                              text:
                                  '\nUnpaid: ${currencyFormat.format(unpaid)}',
                              style: TextStyle(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
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
                        if (value < 0 || value >= allKeys.length)
                          return const SizedBox.shrink();
                        final key = allKeys[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            key.length > 7
                                ? key.substring(key.length - 4)
                                : key,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
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
                        if (value == 0 || value == meta.max)
                          return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 10,
                              ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0
                      ? (maxVal / 4 == 0 ? 1 : maxVal / 4)
                      : 1,
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
                    barsSpace: barsSpace,
                    barRods: [
                      if (widget.config.enablePaidUnpaid) ...[
                        BarChartRodData(
                          toY: paid,
                          width: barWidth,
                          color: colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: unpaid,
                          width: barWidth,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ] else ...[
                        BarChartRodData(
                          toY: paid + unpaid,
                          width: barWidth * 2,
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Renders a real pie chart using fl_chart
  Widget _buildPieChart(BuildContext context, Map<String, dynamic> rawData) {
    final Map<String, Map<String, double>> groupedData = {};

    if (widget.config.enablePaidUnpaid && rawData.containsKey('paid')) {
      final paid = Map<String, double>.from(rawData['paid'] as Map);
      final unpaid = Map<String, double>.from(rawData['unpaid'] as Map);
      for (final k in {...paid.keys, ...unpaid.keys}) {
        groupedData[k] = {
          'paid': paid[k] ?? 0,
          'unpaid': unpaid[k] ?? 0,
        };
      }
    } else {
      final flat = Map<String, double>.from(rawData);
      for (final k in flat.keys) {
        groupedData[k] = {'total': flat[k]!};
      }
    }

    if (groupedData.isEmpty) return _emptyState(context);

    // Sort groups by total category value
    final sortedGroups = groupedData.entries.toList()
      ..sort((a, b) {
        final aTotal = a.value.values.fold<double>(0, (s, v) => s + v);
        final bTotal = b.value.values.fold<double>(0, (s, v) => s + v);
        return bTotal.compareTo(aTotal);
      });

    final totalValue = sortedGroups.fold<double>(
      0, (s, e) => s + e.value.values.fold<double>(0, (s2, v) => s2 + v)
    );
    final spacerValue = totalValue * 0.015;

    final List<PieChartSectionData> sections = [];
    final List<Map<String, dynamic>> legendItems = [];
    final colors = _paletteColors(context);
    final currencyFormat = NumberFormat.compactCurrency(
      symbol: '₹',
      decimalDigits: 0,
    );

    for (int i = 0; i < sortedGroups.length; i++) {
      final group = sortedGroups[i];
      final baseKey = group.key;
      final parts = group.value;

      Color color = colors[i % colors.length];
      String name = baseKey;
      
      if (widget.config.metric == ReportMetric.spendByCategory && widget.categories != null) {
        final cat = widget.categories!.where((c) => c.id == baseKey).firstOrNull;
        if (cat != null) {
          color = cat.color;
          name = cat.name;
        }
      }

      void addSection(double val, String suffix, Color c) {
        if (val <= 0) return;
        final pct = totalValue > 0 ? (val / totalValue * 100) : 0.0;
        sections.add(
          PieChartSectionData(
            color: c,
            value: val,
            title: '${pct.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        );
        legendItems.add({
          'color': c,
          'name': '$name$suffix',
          'value': val,
        });
      }

      if (parts.containsKey('total')) {
        addSection(parts['total']!, '', color);
      } else {
        final paid = parts['paid'] ?? 0;
        final unpaid = parts['unpaid'] ?? 0;
        
        final paidColor = Color.lerp(color, Colors.black, 0.2) ?? color;
        final unpaidColor = Color.lerp(color, Colors.white, 0.4) ?? color;

        // Paid goes first, then unpaid
        addSection(paid, ' (Paid)', paidColor);
        addSection(unpaid, ' (Unpaid)', unpaidColor);
      }

      // Add a spacer after the group, except for the last one
      if (i < sortedGroups.length - 1) {
        sections.add(
          PieChartSectionData(
            color: Theme.of(context).colorScheme.surface,
            value: spacerValue,
            title: '',
            radius: 50,
          )
        );
      }
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Wrap(
            spacing: 14,
            runSpacing: 8,
            children: legendItems.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (item['color'] as Color).withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item['name']} (${currencyFormat.format(item['value'])})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Renders vendor leaderboard as a ranked list with horizontal bars
  Widget _buildLeaderboard(BuildContext context, Map<String, dynamic> rawData) {
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

    final maxVal = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final currencyFormat = NumberFormat.compactCurrency(
      symbol: '₹',
      decimalDigits: 0,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: entries.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final e = entry.value;
        final ratio = maxVal > 0 ? e.value / maxVal : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: rank <= 3
                ? colorScheme.primary.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: rank <= 3
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.outlineVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#$rank',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: rank <= 3
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(
                  e.key,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                    color: rank == 1
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(
                            alpha: 0.5 + ratio * 0.4,
                          ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                currencyFormat.format(e.value),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 36,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
