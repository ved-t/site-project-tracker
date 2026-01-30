import 'package:flutter/material.dart';
import 'package:site_project_tracker/features/sites/settings/presentation/screens/manage_categories_screen.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../../../../../../../core/widgets/settings_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoriesSection extends StatelessWidget {
  final String siteId;

  const CategoriesSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Expense Categories',
      subtitle: 'Add or remove categories',
      children: [
        SettingsTile(
          icon: LucideIcons.layoutGrid,
          title: 'Manage Categories',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageCategoriesScreen(siteId: siteId),
              ),
            );
          },
        ),
      ],
    );
  }
}
