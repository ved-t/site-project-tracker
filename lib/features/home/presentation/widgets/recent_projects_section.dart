import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../../../core/widgets/interactive_card.dart';
import '../../../../../core/widgets/animated_gradient_border_card.dart';

class RecentProjectsSection extends StatelessWidget {
  final List<Project> projects;
  final List<Expense> expenses;

  const RecentProjectsSection({
    super.key,
    required this.projects,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final recentProjectIds = expenses
        .map((e) => e.siteId)
        .toSet()
        .take(5)
        .toList();

    final recentProjects = projects
        .where((p) => recentProjectIds.contains(p.id))
        .toList();

    if (recentProjects.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recent Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
            scrollDirection: Axis.horizontal,
            itemCount: recentProjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final project = recentProjects[index];
              return InteractiveCard(
                onTap: () => context.go('/expenses/${project.id}'),
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: AnimatedGradientBorderCard(
                  borderRadius: 16,
                  color: Theme.of(context).colorScheme.surface,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.apartment,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                project.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.location,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
