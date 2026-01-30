import 'package:flutter/material.dart';
import '../../../../../../../core/widgets/section_card.dart';
import '../sheets/edit_site_details_sheet.dart';
import '../../../../../../../core/utils/dialog_utils.dart';
import '../../../../../../../core/widgets/settings_tile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SiteDetailsSection extends StatelessWidget {
  final String siteId;

  const SiteDetailsSection({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Site Details',
      children: [
        SettingsTile(
          icon: LucideIcons.pencil,
          title: 'Edit Site Name & Location',
          onTap: () {
            showAnimatedDialog(
              context,
              Dialog(
                insetPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: EditSiteDetailsSheet(siteId: siteId),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
