import 'package:flutter/material.dart';
import '../settings/presentation/screens/site_settings_screen.dart';

class SiteSettingsTab extends StatelessWidget {
  final String siteId;

  const SiteSettingsTab({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return SiteSettingsScreen(siteId: siteId);
  }
}
