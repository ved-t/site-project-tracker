import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/widgets/bouncing_button.dart';
import '../../../../../projects/domain/entities/project.dart';
import '../../../../../projects/presentation/controllers/project_controller.dart';

class EditSiteDetailsSheet extends StatefulWidget {
  final String siteId;

  const EditSiteDetailsSheet({super.key, required this.siteId});

  @override
  State<EditSiteDetailsSheet> createState() => _EditSiteDetailsSheetState();
}

class _EditSiteDetailsSheetState extends State<EditSiteDetailsSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  Project? _project;

  @override
  void initState() {
    super.initState();
    final projectController = Provider.of<ProjectController>(
      context,
      listen: false,
    );
    _project = projectController.projects.firstWhere(
      (p) => p.id == widget.siteId,
    );

    _nameCtrl = TextEditingController(text: _project?.name);
    _locationCtrl = TextEditingController(text: _project?.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    if (_project == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Project not found'),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Site Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Site Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: BouncingButton(
              child: ElevatedButton(
                onPressed: () async {
                  final updatedProject = _project!.copyWith(
                    name: _nameCtrl.text.trim(),
                    location: _locationCtrl.text.trim(),
                  );

                  await context.read<ProjectController>().editProject(
                    updatedProject,
                  );

                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
