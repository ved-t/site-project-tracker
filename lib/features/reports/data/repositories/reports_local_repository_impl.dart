import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';
import 'package:site_project_tracker/features/reports/domain/repositories/reports_repository.dart';

class ReportsLocalRepositoryImpl implements ReportsRepository {
  ReportsLocalRepositoryImpl(dynamic expenseRepository);

  @override
  Future<SiteReport> getSiteReport({
    required String siteId,
    DateTime? start,
    DateTime? end,
  }) async {
    throw UnimplementedError(
      "Local reports are being replaced by backend reports",
    );
  }
}
