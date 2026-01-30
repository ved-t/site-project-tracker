import 'package:flutter/material.dart';
import '../../../../../../../core/widgets/section_card.dart';

class PhaseStructureSection extends StatelessWidget {
  final String siteId;

  const PhaseStructureSection({super.key, required this.siteId});

  //   List<Phase> phases; // ordered list
  // Later → use ReorderableListView.

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Project Phases',
      subtitle: 'Customize & reorder phases',
      children: [
        ListTile(
          leading: const Icon(Icons.account_tree),
          title: const Text('Manage Phases'),
          subtitle: const Text('Coming soon'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}
