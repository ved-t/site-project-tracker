import 'package:dio/dio.dart';
import 'package:site_project_tracker/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:site_project_tracker/features/reports/data/models/site_report_model.dart';

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;

  ReportsRemoteDataSourceImpl(this.dio);

  @override
  Future<SiteReportModel> fetchReport(
    String siteId, {
    DateTime? start,
    DateTime? end,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (start != null) {
      queryParams['start_date'] = start.toIso8601String().split('T').first;
    }
    if (end != null) {
      queryParams['end_date'] = end.toIso8601String().split('T').first;
    }

    final response = await dio.get(
      '/reports/sites/$siteId',
      queryParameters: queryParams,
    );

    return SiteReportModel.fromJson(response.data);
  }
}
