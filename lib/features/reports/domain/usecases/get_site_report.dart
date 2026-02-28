import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';
import 'package:site_project_tracker/features/reports/domain/repositories/reports_repository.dart';

class GetSiteReport {
  final ReportsRepository repository;

  GetSiteReport(this.repository);

  Future<SiteReport> call(
    String siteId,
    DateTime start,
    DateTime end,
  ) {
    return repository.getSiteReport(
      siteId: siteId,
      start: start,
      end: end,
    );
  }
}
