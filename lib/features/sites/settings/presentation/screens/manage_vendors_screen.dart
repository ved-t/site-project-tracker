import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:site_project_tracker/features/projects/presentation/controllers/project_controller.dart';
import 'package:site_project_tracker/core/widgets/go_pro_button.dart';
import 'package:site_project_tracker/core/widgets/delete_confirmation_dialog.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/widgets/site_header.dart';
import '../controllers/vendor_controller.dart';
import 'sheets/add_edit_vendor_sheet.dart';
import '../../../../../../core/widgets/app_modal.dart';
import '../../../../../../core/widgets/bouncing_button.dart';
import '../../../../../../core/widgets/interactive_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManageVendorsScreen extends ConsumerWidget {
  final String siteId;

  const ManageVendorsScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = ref.watch(vendorsProvider(siteId));
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
              debugPrint('Go Pro tapped from Vendors');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SiteHeader(title: 'Manage Vendors'),
            Expanded(
              child: vendors.isEmpty
                  ? const Center(child: Text('No vendors added yet'))
                  : ListView.builder(
                      itemCount: vendors.length,
                      itemBuilder: (_, i) {
                        final vendor = vendors[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InteractiveCard(
                            onTap: () {
                              AppModal.show(
                                context,
                                child: AddEditVendorSheet(
                                  siteId: siteId,
                                  vendor: vendor,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              leading: const Icon(LucideIcons.store),
                              title: Text(vendor.name),
                              subtitle: vendor.phone != null
                                  ? Text(vendor.phone!)
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmed =
                                      await DeleteConfirmationDialog.show(
                                        context,
                                        title: 'Delete Vendor',
                                        content:
                                            'Are you sure you want to delete vendor "${vendor.name}"? This action cannot be undone.',
                                      );
                                  if (confirmed) {
                                    await ref
                                        .read(vendorsProvider(siteId).notifier)
                                        .delete(vendor.id);
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
            AppModal.show(
              context,
              child: AddEditVendorSheet(siteId: siteId),
            );
          },
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Vendor'),
        ),
      ),
    );
  }
}
