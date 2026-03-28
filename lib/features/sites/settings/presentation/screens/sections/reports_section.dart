import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../../../../../../../core/widgets/settings_tile.dart';
import 'package:site_project_tracker/features/reports/presentation/screens/reports_page.dart';

class ReportsSection extends StatelessWidget {
  final String siteId;

  const ReportsSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Reports & Analytics',
      subtitle: 'View site performance statistics',
      children: [
        SettingsTile(
          icon: LucideIcons.barChart3,
          title: 'Site Reports',
          onTap: () => _navigateToReports(context),
        ),
      ],
    );
  }

  void _navigateToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Site Report')),
          body: ReportsPage(siteId: siteId),
        ),
      ),
    );
  }
}
