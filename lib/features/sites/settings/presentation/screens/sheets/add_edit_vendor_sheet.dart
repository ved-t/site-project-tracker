import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import '../../../domain/entities/vendor.dart';

import '../../controllers/vendor_controller.dart';
import '../../../../../../core/widgets/bouncing_button.dart';
import '../../../../../../core/widgets/success_checkmark.dart';

class AddEditVendorSheet extends ConsumerStatefulWidget {
  final String siteId;
  final Vendor? vendor;

  const AddEditVendorSheet({super.key, required this.siteId, this.vendor});

  @override
  ConsumerState<AddEditVendorSheet> createState() => _AddEditVendorSheetState();
}

class _AddEditVendorSheetState extends ConsumerState<AddEditVendorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;
  bool _isSuccess = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.vendor?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.vendor?.phone ?? '');
    _notesCtrl = TextEditingController(text: widget.vendor?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final deviceId = await ref.read(localStorageServiceProvider).getDeviceId();

    final vendor = Vendor(
      id: widget.vendor?.id ?? const Uuid().v4(),
      siteId: widget.siteId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.vendor?.createdAt ?? DateTime.now(),
      updatedAt: widget.vendor?.updatedAt ?? DateTime.now(),
      deviceId: widget.vendor?.deviceId ?? deviceId,
    );

    await ref.read(vendorsProvider(widget.siteId).notifier).save(vendor);

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

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.vendor == null ? 'Add Vendor' : 'Edit Vendor',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Vendor Name',
                // border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                // border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                // border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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
