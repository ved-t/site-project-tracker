import '../enums/chart_type.dart';
import '../enums/report_metric.dart';
import '../enums/granularity.dart';

class ReportSection {
  final String id;
  final String siteId;
  final ChartType chartType;
  final ReportMetric metric;
  final Granularity? granularity;

  final bool enableDateFilter;
  final bool enablePaidUnpaid;

  ReportSection({
    required this.id,
    required this.siteId,
    required this.chartType,
    required this.metric,
    this.granularity,
    this.enableDateFilter = false,
    this.enablePaidUnpaid = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'chartType': chartType.name,
      'metric': metric.name,
      'granularity': granularity?.name,
      'enableDateFilter': enableDateFilter,
      'enablePaidUnpaid': enablePaidUnpaid,
    };
  }

  factory ReportSection.fromJson(Map<String, dynamic> json) {
    return ReportSection(
      id: json['id'] as String,
      siteId: json['siteId'] as String? ?? '', // Fallback for old data if any
      chartType: ChartType.values.byName(json['chartType'] as String),
      metric: ReportMetric.values.byName(json['metric'] as String),
      granularity: json['granularity'] != null
          ? Granularity.values.byName(json['granularity'] as String)
          : null,
      enableDateFilter: json['enableDateFilter'] as bool? ?? false,
      enablePaidUnpaid: json['enablePaidUnpaid'] as bool? ?? false,
    );
  }
}