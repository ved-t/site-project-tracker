import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/site_expenses_tab.dart';
import 'tabs/expense_recording_tab.dart';
// import 'tabs/site_phases_tab.dart';
import 'tabs/site_settings_tab.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../projects/presentation/controllers/project_controller.dart';
import '../projects/domain/entities/project.dart';
import '../../core/widgets/go_pro_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'presentation/controllers/site_shell_controller.dart';

class SiteShellScreen extends ConsumerStatefulWidget {
  final String siteId;

  const SiteShellScreen({super.key, required this.siteId});

  @override
  ConsumerState<SiteShellScreen> createState() => _SiteShellScreenState();
}

class _SiteShellScreenState extends ConsumerState<SiteShellScreen> {
  late final List<Widget> _tabs = [
    ExpenseRecordingTab(siteId: widget.siteId),
    SiteExpensesTab(siteId: widget.siteId),
    // SitePhasesTab(siteId: widget.siteId),
    SiteSettingsTab(siteId: widget.siteId),
  ];

  @override
  void dispose() {
    // Reset tab index and editing state when leaving the site shell
    // Use Future.microtask to avoid modifying providers during dispose
    Future.microtask(() {
      // ignore: unused_result
      try {
        ref.read(siteShellTabIndexProvider.notifier).state = 0;
        ref.read(editingExpenseProvider.notifier).state = null;
      } catch (_) {}
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(siteShellTabIndexProvider);
    final projectController = provider_pkg.Provider.of<ProjectController>(context);

    Project? project;
    try {
      project = projectController.projects.firstWhere(
        (p) => p.id == widget.siteId,
      );
    } catch (_) {
      project = null;
    }

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
      body: IndexedStack(index: currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // If user taps Expense tab while already on it, clear any editing state
          if (index == 0 && currentIndex == 0) {
            ref.read(editingExpenseProvider.notifier).state = null;
          }
          ref.read(siteShellTabIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.badgePlus),
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
