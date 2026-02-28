import 'package:site_project_tracker/features/reports/data/models/report_common_models.dart';
import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';

class SiteReportModel extends SiteReport {
  const SiteReportModel({
    required super.siteId,
    super.startDate,
    super.endDate,
    required super.totalAmountSpent,
    required super.todayExpense,
    required super.avgExpensePerDay,
    required List<ReportCategorySpendModel> super.categoryWiseSpent,
    required List<ReportVendorSpendModel> super.vendorWiseSpent,
    required ReportSpendOverTimeModel super.spendOverTime,
  });

  factory SiteReportModel.fromJson(Map<String, dynamic> json) {
    return SiteReportModel(
      siteId: json['site_id'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      totalAmountSpent: (json['total_amount_spent'] ?? 0).toDouble(),
      todayExpense: (json['today_expense'] ?? 0).toDouble(),
      avgExpensePerDay: (json['avg_expense_per_day'] ?? 0).toDouble(),
      categoryWiseSpent: (json['category_wise_spent'] as List)
          .map((e) => ReportCategorySpendModel.fromJson(e))
          .toList(),
      vendorWiseSpent: (json['vendor_wise_spent'] as List)
          .map((e) => ReportVendorSpendModel.fromJson(e))
          .toList(),
      spendOverTime: ReportSpendOverTimeModel.fromJson(json['spend_over_time']),
    );
  }
}
