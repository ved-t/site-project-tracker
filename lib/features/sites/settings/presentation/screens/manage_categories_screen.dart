import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:site_project_tracker/features/projects/presentation/controllers/project_controller.dart';
import 'package:site_project_tracker/core/widgets/go_pro_button.dart';
import 'package:site_project_tracker/core/widgets/delete_confirmation_dialog.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/widgets/site_header.dart';
import '../controllers/category_controller.dart';
import 'sheets/add_edit_category_sheet.dart';
import '../../../../../../core/utils/dialog_utils.dart';
import '../../../../../../core/widgets/bouncing_button.dart';
import '../../../../../../core/widgets/interactive_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  final String siteId;

  const ManageCategoriesScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider(siteId));
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
              debugPrint('Go Pro tapped from Categories');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SiteHeader(title: 'Manage Categories'),
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text('No categories added yet'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InteractiveCard(
                            onTap: () {
                              showAnimatedDialog(
                                context,
                                Dialog(
                                  insetPadding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: SingleChildScrollView(
                                    child: AddEditCategorySheet(
                                      siteId: siteId,
                                      category: cat,
                                    ),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: cat.color.withOpacity(0.15),
                                child: Icon(cat.icon, color: cat.color),
                              ),
                              title: Text(cat.name),
                              trailing: IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await DeleteConfirmationDialog.show(
                                        context,
                                        title: 'Delete Category',
                                        content:
                                            'Are you sure you want to delete category "${cat.name}"? This action cannot be undone.',
                                      );
                                  if (confirmed) {
                                    await ref
                                        .read(
                                          categoriesProvider(siteId).notifier,
                                        )
                                        .delete(cat.id);
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
      floatingActionButton: BouncingButton(
        child: FloatingActionButton.extended(
          onPressed: () {
            showAnimatedDialog(
              context,
              Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: AddEditCategorySheet(siteId: siteId),
                ),
              ),
            );
          },
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Category'),
        ),
      ),
    );
  }
}
