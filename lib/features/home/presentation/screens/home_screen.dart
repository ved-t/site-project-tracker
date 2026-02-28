import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:site_project_tracker/core/widgets/go_pro_button.dart';
import 'package:site_project_tracker/features/home/presentation/widgets/ai_quick_input.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:site_project_tracker/features/home/presentation/widgets/app_drawer.dart';

import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../../projects/presentation/controllers/project_controller.dart';

import '../widgets/recent_projects_section.dart';
import '../widgets/recent_expenses_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch expenses using Riverpod
    final expenses = ref.watch(expenseControllerProvider);

    // Watch projects using Provider package
    final projectController = provider.Provider.of<ProjectController>(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          GoProButton(
            onTap: () {
              // Later: Navigator.push to Pro page
              debugPrint('Go Pro tapped');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger synchronization
          await ref.read(syncManagerProvider).sync();

          await projectController.loadProjects();
          // Read the notifier for the load action
          await ref.read(expenseControllerProvider.notifier).load();
        },

        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // const QuickAddExpenseCard(),
            const AIQuickInput(),

            const SizedBox(height: 24),

            RecentProjectsSection(
              projects: projectController.projects,
              expenses: expenses,
            ),

            const SizedBox(height: 24),

            RecentExpensesSection(expenses: expenses),
          ],
        ),
      ),
    );
  }
}
