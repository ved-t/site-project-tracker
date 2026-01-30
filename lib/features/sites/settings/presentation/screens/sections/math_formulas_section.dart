import 'package:flutter/material.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../../../formulas/presentation/screens/formulas_list_screen.dart';
import '../../../../../../../core/widgets/settings_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MathFormulasSection extends StatelessWidget {
  final String siteId;

  const MathFormulasSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Custom Math Formulas',
      subtitle: 'Used in calculator',
      children: [
        SettingsTile(
          icon: LucideIcons.sigma,
          title: 'Manage Formulas',
          subtitle: 'Create and edit formulas',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FormulasListScreen(siteId: siteId),
              ),
            );
          },
        ),
      ],
    );
  }
}
