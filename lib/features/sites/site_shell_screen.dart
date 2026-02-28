import 'package:flutter/material.dart';
import 'tabs/site_expenses_tab.dart';
import 'tabs/expense_recording_tab.dart';
// import 'tabs/site_phases_tab.dart';
import 'tabs/site_settings_tab.dart';
import 'package:provider/provider.dart';
import '../projects/presentation/controllers/project_controller.dart';
import '../projects/domain/entities/project.dart';
import '../../core/widgets/go_pro_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SiteShellScreen extends StatefulWidget {
  final String siteId;

  const SiteShellScreen({super.key, required this.siteId});

  @override
  State<SiteShellScreen> createState() => _SiteShellScreenState();
}

class _SiteShellScreenState extends State<SiteShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    ExpenseRecordingTab(siteId: widget.siteId),
    SiteExpensesTab(siteId: widget.siteId),
    // SitePhasesTab(siteId: widget.siteId),
    SiteSettingsTab(siteId: widget.siteId),
  ];

  @override
  Widget build(BuildContext context) {
    final projectController = Provider.of<ProjectController>(context);

    // Use try-catch or collection search to safely get the project
    // Assuming Dart 3, .firstOrNull is available on Iterable.
    // If not, we can use .cast<Project?>().firstWhere(..., orElse: () => null) or try/catch.
    // Let's use a safe approach compatible with recent Dart versions.

    Project? project;
    try {
      project = projectController.projects.firstWhere(
        (p) => p.id == widget.siteId,
      );
    } catch (_) {
      project = null;
    }

    // If project is not found yet, show loading (or handle error if it persists, but for "split second" loading is appropriate)
    if (project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          GoProButton(
            onTap: () {
              debugPrint('Go Pro tapped from Site Shell');
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.badgePlus), // or LucideIcons.plusCircle
            label: 'Expense',
          ),
          NavigationDestination(icon: Icon(LucideIcons.receipt), label: 'Site'),
          // NavigationDestination(icon: Icon(Icons.account_tree), label: 'Phase'),
          NavigationDestination(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
