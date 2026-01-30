import 'package:flutter/material.dart';
import '../../../../../../core/widgets/bouncing_button.dart';

class EditSiteDetailsSheet extends StatefulWidget {
  final String siteId;

  const EditSiteDetailsSheet({super.key, required this.siteId});

  @override
  State<EditSiteDetailsSheet> createState() => _EditSiteDetailsSheetState();
}

class _EditSiteDetailsSheetState extends State<EditSiteDetailsSheet> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit Site Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Site Name',
              // border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              labelText: 'Location',
              // border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          BouncingButton(
            child: ElevatedButton(
              onPressed: () {
                // save locally (Hive / provider)
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
