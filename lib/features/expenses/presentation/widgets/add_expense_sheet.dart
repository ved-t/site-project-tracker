import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/expenses/presentation/widgets/calculator_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../controllers/expense_controller.dart';
import '../../../sites/settings/presentation/controllers/category_controller.dart';
import '../../../sites/settings/presentation/controllers/vendor_controller.dart';
import '../../../sites/settings/domain/entities/vendor.dart';
import '../../../../../core/utils/dialog_utils.dart';
import '../../../../../core/widgets/success_checkmark.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final String siteId;
  const AddExpenseSheet({super.key, required this.siteId});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isAmountLocked = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSubmitting = true);

    final expense = Expense(
      id: const Uuid().v4(),
      siteId: widget.siteId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory!,
      vendor: _vendorController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ref.read(expenseControllerProvider.notifier).addExpense(expense);

    ref.invalidate(projectExpensesProvider(widget.siteId));

    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showVendorPicker(List<Vendor> vendors) {
    showAnimatedDialog(
      context,
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Vendor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vendors.length,
                itemBuilder: (_, i) {
                  final v = vendors[i];
                  return ListTile(
                    title: Text(v.name),
                    onTap: () {
                      _vendorController.text = v.name;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Watch Categories & Vendors
    final categories = ref.watch(categoriesProvider(widget.siteId));
    final vendors = ref.watch(vendorsProvider(widget.siteId));

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Text(
                'Add Expense',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// Amount Field
              TextFormField(
                controller: _amountController,
                readOnly: _isAmountLocked,
                decoration: InputDecoration(
                  labelText: _isAmountLocked ? 'Amount (Calculated)' : 'Amount',
                  // border: const OutlineInputBorder(),
                  prefixText: '₹ ',
                  hintText: 'Enter amount or use calculator',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isAmountLocked
                          ? LucideIcons.lock
                          : LucideIcons.calculator,
                    ),
                    onPressed: () {
                      showAnimatedDialog(
                        context,
                        Dialog(
                          insetPadding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            child: CalculatorSheet(
                              siteId: widget.siteId,
                              initialValue: double.tryParse(
                                _amountController.text,
                              ),
                              onApply: (value) {
                                setState(() {
                                  _amountController.text = value
                                      .toStringAsFixed(2);
                                  _isAmountLocked = true;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  if (!_isAmountLocked) {
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Description Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Cement Purchase',
                  // border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),

              const SizedBox(height: 16),

              /// Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  // border: OutlineInputBorder(),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.name,
                    child: Row(
                      // Note: Category icons are stored as code points, we might need to handle this separately if they were Material Icons code points.
                      // But assume they are IconData. If they were Material, we might want to map them?
                      // For now, keep as is unless category icons are also migrated.
                      children: [
                        Icon(cat.icon, size: 20, color: cat.color),
                        const SizedBox(width: 10),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Select a category' : null,
              ),

              const SizedBox(height: 16),

              /// Vendor Field
              TextFormField(
                controller: _vendorController,
                decoration: InputDecoration(
                  labelText: 'Vendor/Supplier',
                  hintText: 'e.g. ABC Traders',
                  // border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.chevronDown),
                    onPressed: () => _showVendorPicker(vendors),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vendor is required'
                    : null,
              ),

              const SizedBox(height: 16),

              /// Remarks Field
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  // border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              /// Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    // border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                      const Icon(LucideIcons.calendar, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _isSuccess ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _isSuccess ? Colors.green : null,
                  ),
                  child: _isSuccess
                      ? const SuccessCheckmark(color: Colors.white)
                      : _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
