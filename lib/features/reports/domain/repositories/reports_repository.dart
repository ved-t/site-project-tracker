import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';

abstract class ReportsRepository {
  Future<SiteReport> getSiteReport({
    required String siteId,
    DateTime? start,
    DateTime? end,
  });
}
