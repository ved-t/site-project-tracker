import 'package:site_project_tracker/features/reports/data/models/site_report_model.dart';

abstract class ReportsRemoteDataSource {
  Future<SiteReportModel> fetchReport(
    String siteId, {
    DateTime? start,
    DateTime? end,
  });
}
