import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart'; // Unused
// import 'package:site_project_tracker/core/services/local_storage_service.dart'; // Unused
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:site_project_tracker/features/reports/data/datasources/reports_remote_datasource_impl.dart';
import 'package:site_project_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:site_project_tracker/features/reports/domain/usecases/get_site_report.dart';
import 'package:site_project_tracker/features/reports/presentation/controllers/reports_controller.dart';
import 'package:site_project_tracker/features/reports/presentation/screens/reports_page.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../../../../../../../core/widgets/settings_tile.dart';

class ReportsSection extends ConsumerWidget {
  final String siteId;

  const ReportsSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Reports & Analytics',
      subtitle: 'View site performance statistics',
      children: [
        SettingsTile(
          icon: LucideIcons.barChart3,
          title: 'Site Reports',
          onTap: () => _navigateToReports(context, ref),
        ),
      ],
    );
  }

  void _navigateToReports(BuildContext context, WidgetRef ref) {
    // 1. Get Dependencies
    // Note: LocalStorageService is provided via Provider, not Riverpod in this scope, but we don't strictly need it for ReportsRemoteDataSource.
    // We need Dio for remote data source.
    final dio = ref.read(dioProvider);

    // 2. Setup Repository Stack
    final reportsRemoteDs = ReportsRemoteDataSourceImpl(dio);
    final reportsRepo = ReportsRepositoryImpl(reportsRemoteDs);
    final getSiteReport = GetSiteReport(reportsRepo);

    // 3. Navigate
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => p.ChangeNotifierProvider(
          create: (_) => ReportsController(getSiteReport)
            ..load(
              siteId,
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Site Report')),
            body: ReportsPage(siteId: siteId),
          ),
        ),
      ),
    );
  }
}
