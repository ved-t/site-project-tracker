import 'package:flutter/material.dart';
import 'sections/site_details_section.dart';
// import 'sections/phase_structure_section.dart';
import 'sections/math_formulas_section.dart';
import 'sections/categories_section.dart';
import 'sections/vendors_section.dart';
import 'sections/reports_section.dart';
import '../widgets/site_header.dart';

class SiteSettingsScreen extends StatelessWidget {
  final String siteId;

  const SiteSettingsScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SiteHeader(title: 'Site Settings'),
        SiteDetailsSection(siteId: siteId),
        const SizedBox(height: 12),
        // PhaseStructureSection(siteId: siteId),
        // const SizedBox(height: 24),
        MathFormulasSection(siteId: siteId),
        const SizedBox(height: 12),
        CategoriesSection(siteId: siteId),
        const SizedBox(height: 12),
        VendorsSection(siteId: siteId),
        const SizedBox(height: 12),
        ReportsSection(siteId: siteId),
      ],
    );
  }
}
