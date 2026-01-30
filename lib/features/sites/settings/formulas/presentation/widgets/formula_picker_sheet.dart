import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/core/widgets/interactive_card.dart';
import '../controllers/formulas_controller.dart';
import '../../domain/entities/formula.dart';

class FormulaPickerSheet extends ConsumerWidget {
  final String siteId;
  final void Function(Formula formula) onSelected;

  const FormulaPickerSheet({
    super.key,
    required this.siteId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real formulas provider from site settings
    final formulas = ref.watch(formulasProvider(siteId));

    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select Formula',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (formulas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'No formulas found.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Instructions or navigation could go here
                    // For now just close or show info
                    Navigator.pop(context);
                    // Ideally navigate to manage formulas:
                    // context.push('/sites/$siteId/settings/formulas');
                    // but context.push might not be readily available or we are in a sheet.
                  },
                  child: const Text('Go to Settings to add formulas'),
                ),
              ],
            ),
          )
        else
          ...formulas.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: InteractiveCard(
                onTap: () {
                  onSelected(f);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.functions),
                  title: Text(f.name),
                  subtitle: Text(f.expression),
                ),
              ),
            );
          }),
      ],
    );
  }
}
