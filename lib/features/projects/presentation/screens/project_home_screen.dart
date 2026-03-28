import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';
import 'package:site_project_tracker/features/projects/domain/entities/project.dart';
import 'package:site_project_tracker/core/widgets/go_pro_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/bouncing_button.dart';
import '../../../../core/widgets/success_checkmark.dart';

import '../controllers/project_controller.dart';
import '../widgets/project_card.dart';
import '../widgets/empty_projects_placeholder.dart';

class ProjectHomeScreen extends StatefulWidget {
  const ProjectHomeScreen({super.key});

  @override
  State<ProjectHomeScreen> createState() => _ProjectHomeScreenState();
}

class _ProjectHomeScreenState extends State<ProjectHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProjectController>().loadProjects());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Projects'),
        actions: [
          GoProButton(
            onTap: () {
              debugPrint('Go Pro tapped from Your Projects');
            },
          ),
        ],
      ),

      floatingActionButton: BouncingButton(
        child: FloatingActionButton.extended(
          onPressed: () => _openCreateProjectSheet(context),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add Project'),
        ),
      ),

      body: controller.projects.isEmpty
          ? const EmptyProjectsPlaceholder()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: controller.projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  return ProjectCard(
                    project: controller.projects[index],
                    onTap: () => context.go(
                      '/expenses/${controller.projects[index].id}',
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _openCreateProjectSheet(BuildContext context) {
    AppModal.show(
      context,
      borderRadius: 20,
      child: const _CreateProjectSheet(),
    );
  }
}

class _CreateProjectSheet extends StatefulWidget {
  const _CreateProjectSheet();

  @override
  State<_CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<_CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Project',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: BouncingButton(
                child: ElevatedButton(
                  onPressed: _isSubmitting || _isSuccess
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isSubmitting = true);

                          final deviceId = await context
                              .read<LocalStorageService>()
                              .getDeviceId();
                          await context.read<ProjectController>().createProject(
                            Project(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              location: locationController.text,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              deviceId: deviceId,
                            ),
                          );

                          setState(() {
                            _isSubmitting = false;
                            _isSuccess = true;
                          });
                          await Future.delayed(
                            const Duration(milliseconds: 1000),
                          );

                          if (context.mounted) Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuccess ? Colors.green : null,
                  ),
                  child: _isSuccess
                      ? const SuccessCheckmark(color: Colors.white)
                      : _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Project'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
