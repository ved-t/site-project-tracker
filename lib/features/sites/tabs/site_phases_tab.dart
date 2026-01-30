import 'package:flutter/material.dart';
import '../settings/presentation/widgets/site_header.dart';

class SitePhasesTab extends StatelessWidget {
  final String siteId;

  const SitePhasesTab({super.key, required this.siteId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SiteHeader(title: 'Project Phases'),
        _PhaseTile('Initiation / Conception'),
        _PhaseTile('Planning & Design'),
        _PhaseTile('Pre-Construction'),
        _PhaseTile('Procurement'),
        _PhaseTile('Construction'),
        _PhaseTile('Post-Construction / Closeout'),
      ],
    );
  }
}

class _PhaseTile extends StatelessWidget {
  final String title;

  const _PhaseTile(this.title);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        subtitle: const Text('Coming soon'),
      ),
    );
  }
}
