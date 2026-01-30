import 'package:flutter/material.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../manage_vendors_screen.dart';
import '../../../../../../../core/widgets/settings_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VendorsSection extends StatelessWidget {
  final String siteId;

  const VendorsSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Vendors / Suppliers',
      subtitle: 'Quick access while adding expenses',
      children: [
        SettingsTile(
          icon: LucideIcons.store,
          title: 'Manage Vendors',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageVendorsScreen(siteId: siteId),
              ),
            );
          },
        ),
      ],
    );
  }
}
