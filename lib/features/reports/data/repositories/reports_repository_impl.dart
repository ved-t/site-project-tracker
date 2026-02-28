import 'package:site_project_tracker/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';
import 'package:site_project_tracker/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remote;

  ReportsRepositoryImpl(this.remote);

  @override
  Future<SiteReport> getSiteReport({
    required String siteId,
    DateTime? start,
    DateTime? end,
  }) async {
    return await remote.fetchReport(siteId, start: start, end: end);
  }
}
