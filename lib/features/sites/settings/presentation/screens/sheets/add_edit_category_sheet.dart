import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import '../../../domain/entities/category.dart';

import '../../controllers/category_controller.dart';
import '../../../../../../core/widgets/bouncing_button.dart';
import '../../../../../../core/widgets/success_checkmark.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddEditCategorySheet extends ConsumerStatefulWidget {
  final String siteId;
  final ExpenseCategoryEntity? category;

  const AddEditCategorySheet({super.key, required this.siteId, this.category});

  @override
  ConsumerState<AddEditCategorySheet> createState() =>
      _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends ConsumerState<AddEditCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  late IconData _icon;
  late Color _color;
  bool _isSuccess = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.category?.name ?? '';
    _icon = widget.category?.icon ?? LucideIcons.layoutGrid;
    _color = widget.category?.color ?? Colors.blue;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final deviceId = await ref.read(localStorageServiceProvider).getDeviceId();

    final category = ExpenseCategoryEntity(
      id: widget.category?.id ?? const Uuid().v4(),
      siteId: widget.siteId,
      name: _nameCtrl.text.trim(),
      icon: _icon,
      color: _color,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: widget.category?.updatedAt ?? DateTime.now(),
      deviceId: widget.category?.deviceId ?? deviceId,
    );

    await ref.read(categoriesProvider(widget.siteId).notifier).save(category);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category == null ? 'Add Category' : 'Edit Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Category Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            /// Icon picker (simple preset)
            Wrap(
              spacing: 12,
              children:
                  [
                    LucideIcons.hammer,
                    LucideIcons.store,
                    LucideIcons.wrench,
                    LucideIcons.layoutGrid,
                    LucideIcons.moreHorizontal,
                  ].map((icon) {
                    return ChoiceChip(
                      selected: _icon == icon,
                      label: Icon(icon),
                      onSelected: (_) => setState(() => _icon = icon),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            /// Color picker (preset)
            Wrap(
              spacing: 12,
              children:
                  [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                    Colors.purple,
                  ].map((c) {
                    return GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: CircleAvatar(
                        backgroundColor: c,
                        child: _color == c
                            ? const Icon(LucideIcons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: BouncingButton(
                child: ElevatedButton(
                  onPressed: _isSaving || _isSuccess ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuccess ? Colors.green : null,
                  ),
                  child: _isSuccess
                      ? const SuccessCheckmark(color: Colors.white)
                      : _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
