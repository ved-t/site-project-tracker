import 'package:flutter/material.dart';
import 'package:site_project_tracker/features/reports/domain/entities/site_report.dart';
import 'package:site_project_tracker/features/reports/domain/usecases/get_site_report.dart';

class ReportsController extends ChangeNotifier {
  final GetSiteReport getSiteReport;

  SiteReport? report;
  bool loading = false;

  ReportsController(this.getSiteReport);

  String? errorMessage;
  String? _lastSiteId;
  DateTime? _lastStart;
  DateTime? _lastEnd;

  Future<void> load(String siteId, DateTime start, DateTime end) async {
    _lastSiteId = siteId;
    _lastStart = start;
    _lastEnd = end;

    try {
      loading = true;
      errorMessage = null;
      notifyListeners();

      report = await getSiteReport(siteId, start, end);
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains("timeout")) {
        errorMessage = "Connection timed out. Please check your network.";
      } else if (errorString.contains("SocketException") ||
          errorString.contains("DioException")) {
        errorMessage = "Network error. Please check your connection.";
      } else {
        errorMessage = "An unexpected error occurred.";
      }
      debugPrint("Reports Error: $e"); // Log the real error
      report = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void retry() {
    if (_lastSiteId != null && _lastStart != null && _lastEnd != null) {
      load(_lastSiteId!, _lastStart!, _lastEnd!);
    }
  }
}
