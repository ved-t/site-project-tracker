import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import '../../expenses/domain/entities/expense.dart';
import '../presentation/controllers/site_shell_controller.dart';

import '../../expenses/presentation/controllers/expense_controller.dart';
import '../../expenses/presentation/widgets/calculator_sheet.dart';
import '../settings/presentation/controllers/category_controller.dart';
import '../settings/presentation/controllers/vendor_controller.dart';
import '../settings/domain/entities/vendor.dart';
import '../settings/domain/entities/category.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/widgets/success_checkmark.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/toast_utils.dart';

class ExpenseRecordingTab extends ConsumerStatefulWidget {
  final String siteId;
  const ExpenseRecordingTab({super.key, required this.siteId});

  @override
  ConsumerState<ExpenseRecordingTab> createState() =>
      _ExpenseRecordingTabState();
}

class _ExpenseRecordingTabState extends ConsumerState<ExpenseRecordingTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _remarksController = TextEditingController();
  final _scrollController = ScrollController(); // To scroll to top after submit

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isAmountLocked = false;
  bool _isPaymentCompleted = false;

  // Tracks the ID of the expense being edited (null = add mode)
  String? _editingExpenseId;

  // Helper to show category selection sheet for "More"
  void _showMoreCategoriesSheet(List<ExpenseCategoryEntity> allCategories) {
    showAnimatedDialog(
      context,
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate width based on available dialog width
                      // available - (spacing * 2) / 3
                      final tileWidth = (constraints.maxWidth - 16.1) / 3;

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allCategories.sublist(5).map((cat) {
                          final isSelected = _selectedCategory == cat.id;
                          return _buildCategoryTile(
                            category: cat,
                            isSelected: isSelected,
                            customWidth: tileWidth,
                            onTap: () {
                              setState(() => _selectedCategory = cat.id);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required ExpenseCategoryEntity category,
    required bool isSelected,
    required VoidCallback onTap,
    double? customWidth,
  }) {
    final theme = Theme.of(context);
    // Screen width - (horizontal padding * 2) - (spacing * 2) / 3
    final tileWidth =
        customWidth ?? (MediaQuery.of(context).size.width - 32 - 16.1) / 3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: tileWidth,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              // Use category color, or fallback to theme primary if selected/grey if not?
              // User asked for "the color", implying the category's defined color.
              color: category.color,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTile({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    // Same width calculation
    final tileWidth = (MediaQuery.of(context).size.width - 32 - 16.1) / 3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: tileWidth,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
            style: isSelected ? BorderStyle.solid : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.moreHorizontal,
              color: isSelected ? theme.primaryColor : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              isSelected ? 'Other' : 'More',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _remarksController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _vendorController.clear();
    _remarksController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = null;
      _isAmountLocked = false;
      _isSuccess = false;
      _isPaymentCompleted = false;
      _editingExpenseId = null;
    });
    // Clear the editing provider so the shell knows we're done
    ref.read(editingExpenseProvider.notifier).state = null;
    // Scroll to top
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Populates form fields from an [Expense] entity for editing.
  void _populateFromExpense(Expense expense) {
    _amountController.text = expense.amount.toStringAsFixed(2);
    _titleController.text = expense.title;
    _vendorController.text = expense.vendor;
    _remarksController.text = expense.remarks ?? '';
    setState(() {
      _selectedDate = expense.date;
      _selectedCategory = expense.categoryId;
      _isPaymentCompleted = expense.isPaymentCompleted;
      _isAmountLocked = false;
      _isSuccess = false;
      _editingExpenseId = expense.id;
    });
    // Scroll to top so user sees the filled form
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ToastUtils.show('Please select a category', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final deviceId = await ref.read(localStorageServiceProvider).getDeviceId();
    final isEditing = _editingExpenseId != null;
    final editingExpense = ref.read(editingExpenseProvider);

    final expense = Expense(
      id: isEditing ? _editingExpenseId! : const Uuid().v4(),
      siteId: widget.siteId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      categoryId: _selectedCategory!,
      vendor: _vendorController.text.trim(),
      isPaymentCompleted: _isPaymentCompleted,
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
      createdAt: isEditing ? editingExpense!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    try {
      if (isEditing) {
        await ref.read(expenseControllerProvider.notifier).updateExpense(expense);
      } else {
        await ref.read(expenseControllerProvider.notifier).addExpense(expense);
      }
      // Invalidate provider to refresh list in other tabs
      ref.invalidate(projectExpensesProvider(widget.siteId));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
        });

        // Show success feedback
        ToastUtils.show(
          isEditing ? 'Expense updated successfully' : 'Expense added successfully',
          duration: const Duration(seconds: 2),
        );
      }

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ToastUtils.show('Error ${isEditing ? 'updating' : 'adding'} expense: $e', isError: true);
      }
    }
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
              if (vendors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No vendors found. Type a new one."),
                )
              else
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
    // Listen for changes to the editing expense (triggered from ExpenseRow tap)
    ref.listen<Expense?>(editingExpenseProvider, (previous, next) {
      if (next != null && next.id != _editingExpenseId) {
        _populateFromExpense(next);
      } else if (next == null && _editingExpenseId != null) {
        // Editing was cancelled externally (e.g. user tapped Expense tab again)
        _resetForm();
      }
    });

    final isEditing = _editingExpenseId != null;

    // Watch Categories & Vendors
    final categories = ref.watch(categoriesProvider(widget.siteId));
    final vendors = ref.watch(vendorsProvider(widget.siteId));

    return Scaffold(
      body: _isSuccess
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SuccessCheckmark(size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    isEditing ? 'Expense Updated!' : 'Expense Added!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Optional: Header for the tab
                    /* Text(
                      'New Expense',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24), */

                    /// Amount Field
                    AppTextField(
                      controller: _amountController,
                      readOnly: _isAmountLocked,
                      labelText: _isAmountLocked
                          ? 'Amount (Calculated)'
                          : 'Amount',
                      prefixText: '₹ ',
                      hintText: 'Enter amount',
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
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Description',
                      hintText: 'e.g. Cement Purchase',
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// Category Selection
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        if (categories.isEmpty) {
                          return const Text('No categories found.');
                        }

                        final showMore = categories.length > 6;
                        final displayCount = showMore ? 5 : categories.length;
                        final displayCategories = categories
                            .take(displayCount)
                            .toList();

                        // Check if selected category is in the hidden list (if showMore is true)
                        // If showMore is false, isHiddenSelected is always false.
                        bool isHiddenSelected = false;
                        if (showMore && _selectedCategory != null) {
                          final isVisible = displayCategories.any(
                            (c) => c.id == _selectedCategory,
                          );
                          isHiddenSelected = !isVisible;
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...displayCategories.map((cat) {
                              return _buildCategoryTile(
                                category: cat,
                                isSelected: _selectedCategory == cat.id,
                                onTap: () =>
                                    setState(() => _selectedCategory = cat.id),
                              );
                            }),
                            if (showMore)
                              _buildMoreTile(
                                isSelected: isHiddenSelected,
                                onTap: () =>
                                    _showMoreCategoriesSheet(categories),
                              ),
                          ],
                        );
                      },
                    ),
                    if (_selectedCategory == null &&
                        _isSubmitting) // Simple validation feedback
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Select a category',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    /// Vendor Field
                    AppTextField(
                      controller: _vendorController,
                      labelText: 'Vendor/Supplier',
                      hintText: 'e.g. ABC Traders',
                      suffixIcon: IconButton(
                        icon: const Icon(LucideIcons.chevronDown),
                        onPressed: () => _showVendorPicker(vendors),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vendor is required'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// Payment Completed Checkbox
                    CheckboxListTile(
                      value: _isPaymentCompleted,
                      onChanged: (val) {
                        setState(() {
                          _isPaymentCompleted = val ?? false;
                        });
                      },
                      title: const Text('Is payment completed?'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),

                    const SizedBox(height: 16),

                    /// Date Picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',

                          // border: OutlineInputBorder(), // Removed to match theme
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                            ),
                            const Icon(LucideIcons.calendar, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Remarks Field
                    AppTextField(
                      controller: _remarksController,
                      labelText: 'Remarks (Optional)',
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 24),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEditing ? 'Save edited Expense' : 'Save Expense',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
