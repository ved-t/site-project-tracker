import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:site_project_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:site_project_tracker/core/widgets/app_modal.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/controllers/category_controller.dart';
import '../../domain/entities/report_section.dart';
import '../widgets/create_report_modal.dart';
import '../widgets/report_section_widget.dart';
import '../controllers/report_section_controller.dart';

class ReportsPage extends ConsumerStatefulWidget {
  final String siteId;

  const ReportsPage({super.key, required this.siteId});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(projectExpensesProvider(widget.siteId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final section = await AppModal.show<ReportSection>(
            context,
            child: CreateReportModal(siteId: widget.siteId),
          );

          if (section != null) {
            ref.read(reportSectionsProvider(widget.siteId).notifier).addSection(section);
          }
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Section'),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading expenses: $e')),
        data: (expenses) {
          final sections = ref.watch(reportSectionsProvider(widget.siteId));
          final categories = ref.watch(categoriesProvider(widget.siteId));

          if (sections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.barChart2,
                    size: 72,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No report sections yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add Section" to create your first chart',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: sections.length,
            itemBuilder: (_, index) {
              return ReportSectionWidget(
                config: sections[index],
                expenses: expenses,
                categories: categories,
                onDelete: () => ref.read(reportSectionsProvider(widget.siteId).notifier).removeSection(sections[index].id),
              );
            },
          );
        },
      ),
    );
  }
}