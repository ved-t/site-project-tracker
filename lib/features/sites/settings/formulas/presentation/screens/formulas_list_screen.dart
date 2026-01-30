import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:site_project_tracker/features/projects/presentation/controllers/project_controller.dart';
import 'package:site_project_tracker/core/widgets/go_pro_button.dart';
import 'package:site_project_tracker/core/widgets/delete_confirmation_dialog.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/widgets/site_header.dart';
import '../../../../../../core/widgets/interactive_card.dart';
import '../controllers/formulas_controller.dart';
import 'add_edit_formula_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FormulasListScreen extends ConsumerWidget {
  final String siteId;

  const FormulasListScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formulas = ref.watch(formulasProvider(siteId));
    final projectController = legacy_provider.Provider.of<ProjectController>(
      context,
    );
    final project = projectController.projects.firstWhere(
      (p) => p.id == siteId,
      orElse: () => throw Exception('Project not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          GoProButton(
            onTap: () {
              debugPrint('Go Pro tapped from Formulas');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SiteHeader(title: 'Formulas'),
            Expanded(
              child: formulas.isEmpty
                  ? const Center(child: Text('No formulas yet. Add one!'))
                  : ListView.builder(
                      itemCount: formulas.length,
                      itemBuilder: (context, index) {
                        final formula = formulas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InteractiveCard(
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              title: Text(formula.name),
                              subtitle: Text(formula.expression),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddEditFormulaScreen(
                                      siteId: siteId,
                                      formula: formula,
                                    ),
                                  ),
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await DeleteConfirmationDialog.show(
                                        context,
                                        title: 'Delete Formula',
                                        content:
                                            'Are you sure you want to delete formula "${formula.name}"? This action cannot be undone.',
                                      );
                                  if (confirmed) {
                                    await ref
                                        .read(formulasProvider(siteId).notifier)
                                        .delete(formula.id);
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditFormulaScreen(siteId: siteId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
