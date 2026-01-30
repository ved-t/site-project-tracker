import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:site_project_tracker/core/widgets/delete_confirmation_dialog.dart';
import 'package:site_project_tracker/features/projects/domain/entities/project.dart';
import '../../../../core/widgets/interactive_card.dart';
import '../controllers/project_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getProjectColor(project.name);

    return InteractiveCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Abstract Header / Pattern
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.shade100, color.shade50.withOpacity(0.5)],
                ),
              ),
              child: Stack(
                children: [
                  // Abstract decorative circle
                  Positioned(
                    top: -20,
                    right: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Icon(
                      Icons
                          .business, // Changed icon for variety or keep location_city
                      color: color.shade700,
                      size: 32,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_vert, color: color.shade900),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirmed = await DeleteConfirmationDialog.show(
                              context,
                              title: 'Delete Project',
                              content:
                                  'This will permanently delete the project and all its expenses.',
                            );
                            if (confirmed && context.mounted) {
                              await context
                                  .read<ProjectController>()
                                  .removeProject(project.id);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getProjectColor(String name) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.cyan,
      Colors.deepPurple,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
