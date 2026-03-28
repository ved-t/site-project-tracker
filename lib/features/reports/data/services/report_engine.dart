import '../../domain/entities/report_section.dart';
import '../../domain/enums/report_metric.dart';
import 'cash_outflow_calculator.dart';
import 'category_spend_calculator.dart';
import 'vendor_spend_calculator.dart';
import 'vendor_leaderboard_calculator.dart';

class ReportEngine {
  /// Returns a [Map<String, dynamic>] with chart data.
  ///
  /// When [config.enablePaidUnpaid] is true, the map will contain:
  ///   { 'paid': Map<String, double>, 'unpaid': Map<String, double> }
  ///
  /// For vendorLeaderboard with paid/unpaid, it returns:
  ///   { 'entries': List<MapEntry<String, double>> }
  ///   (combined totals, since leaderboard is always total)
  ///
  /// Otherwise the map is the flat result from the calculator.
  static Map<String, dynamic> generate(
    List<dynamic> expenses,
    ReportSection config,
  ) {
    if (config.enablePaidUnpaid) {
      final paid = expenses.where((e) => e.isPaymentCompleted == true).toList();
      final unpaid =
          expenses.where((e) => e.isPaymentCompleted != true).toList();

      switch (config.metric) {
        case ReportMetric.cashOutflow:
          return {
            'paid': CashOutflowCalculator.compute(paid, config),
            'unpaid': CashOutflowCalculator.compute(unpaid, config),
          };

        case ReportMetric.spendByCategory:
          return {
            'paid': CategorySpendCalculator.compute(paid),
            'unpaid': CategorySpendCalculator.compute(unpaid),
          };

        case ReportMetric.spendByVendor:
          return {
            'paid': VendorSpendCalculator.compute(paid),
            'unpaid': VendorSpendCalculator.compute(unpaid),
          };

        case ReportMetric.vendorLeaderboard:
          // For leaderboard, show combined (paid + unpaid)
          return {
            'entries': VendorLeaderboardCalculator.compute(expenses),
          };
      }
    }

    // No paid/unpaid split: return flat map
    switch (config.metric) {
      case ReportMetric.cashOutflow:
        return CashOutflowCalculator.compute(expenses, config);

      case ReportMetric.spendByCategory:
        return CategorySpendCalculator.compute(expenses);

      case ReportMetric.spendByVendor:
        return VendorSpendCalculator.compute(expenses);

      case ReportMetric.vendorLeaderboard:
        return {
          'entries': VendorLeaderboardCalculator.compute(expenses),
        };
    }
  }
}