import '../../domain/entities/report_section.dart';
import '../../domain/enums/granularity.dart';

class CashOutflowCalculator {
  static Map<String, double> compute(
    List expenses,
    ReportSection config,
  ) {
    Map<String, double> result = {};

    for (var e in expenses) {
      final date = e.date;

      String key;

      switch (config.granularity) {
        case Granularity.daily:
          key = "${date.year}-${date.month}-${date.day}";
          break;

        case Granularity.weekly:
          final week = (date.day / 7).ceil();
          key = "${date.year}-${date.month}-W$week";
          break;

        case Granularity.monthly:
        default:
          key = "${date.year}-${date.month}";
      }

      result[key] = (result[key] ?? 0) + e.amount;
    }

    return result;
  }
}