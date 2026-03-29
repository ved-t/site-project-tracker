import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/dialog_utils.dart';
import '../../../sites/settings/domain/entities/category.dart';
import '../../../sites/settings/presentation/controllers/category_controller.dart';
import '../controllers/expense_filter_controller.dart';
import '../../../../../core/widgets/bouncing_button.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final String siteId;
  const FilterBottomSheet({super.key, required this.siteId});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late List<String> _selectedCategories;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  DateTime? _minDate;
  DateTime? _maxDate;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(expenseFilterProvider);
    _selectedCategories = List.from(currentFilter.categories ?? []);
    _minDate = currentFilter.minDate;
    _maxDate = currentFilter.maxDate;
    if (currentFilter.minAmount != null) {
      _minController.text = currentFilter.minAmount.toString();
    }
    if (currentFilter.maxAmount != null) {
      _maxController.text = currentFilter.maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  // Helper to show category selection sheet for "More"
  void _showMoreCategoriesSheet(List<ExpenseCategoryEntity> allCategories) {
    showAnimatedDialog(
      context,
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
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
                          final tileWidth = (constraints.maxWidth - 16.1) / 3;

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allCategories.sublist(5).map((cat) {
                              final isSelected = _selectedCategories.contains(cat.id);
                              return _buildCategoryTile(
                                category: cat,
                                isSelected: isSelected,
                                customWidth: tileWidth,
                                onTap: () {
                                  _toggleCategory(cat.id);
                                  setDialogState(() {}); // update dialog ui
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
            );
          }
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: customWidth,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              color: category.color,
              size: 18,
            ),
            const SizedBox(height: 3),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
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
    double? customWidth,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: customWidth,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.moreHorizontal,
              color: isSelected ? theme.primaryColor : Colors.grey.shade700,
              size: 18,
            ),
            const SizedBox(height: 3),
            Text(
              isSelected ? 'Other' : 'More',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
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
  Widget build(BuildContext context) {
    final availableCategories = ref.watch(categoriesProvider(widget.siteId));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(expenseFilterProvider.notifier).state =
                      const ExpenseFilter();
                  Navigator.pop(context);
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Category Filter
          Text(
            'Category',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              if (availableCategories.isEmpty) {
                return const Text('No categories found.');
              }

              final showMore = availableCategories.length > 6;
              final displayCount = showMore ? 5 : availableCategories.length;
              final displayCategories = availableCategories
                  .take(displayCount)
                  .toList();

              bool isHiddenSelected = false;
              if (showMore && _selectedCategories.isNotEmpty) {
                isHiddenSelected = _selectedCategories.any((selectedId) =>
                    !displayCategories.any((c) => c.id == selectedId));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final tileWidth = (constraints.maxWidth - spacing * 2) / 3;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      ...displayCategories.map((cat) {
                        return _buildCategoryTile(
                          category: cat,
                          isSelected: _selectedCategories.contains(cat.id),
                          onTap: () => _toggleCategory(cat.id),
                          customWidth: tileWidth,
                        );
                      }),
                      if (showMore)
                        _buildMoreTile(
                          isSelected: isHiddenSelected,
                          onTap: () => _showMoreCategoriesSheet(availableCategories),
                          customWidth: tileWidth,
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          /// Date Range Filter
          Text(
            'Date Filter',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  initialDateRange: _minDate != null && _maxDate != null
                      ? DateTimeRange(start: _minDate!, end: _maxDate!)
                      : null,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (range != null) {
                  setState(() {
                    _minDate = range.start;
                    _maxDate = range.end;
                  });
                }
              },
              icon: const Icon(LucideIcons.calendarDays, size: 16),
              label: Text(
                _minDate != null && _maxDate != null
                    ? (_minDate == _maxDate
                        ? DateFormat('dd MMM yyyy').format(_minDate!)
                        : '${DateFormat('dd MMM').format(_minDate!)} – ${DateFormat('dd MMM yyyy').format(_maxDate!)}')
                    : 'Select Date',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (_minDate != null && _maxDate != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _minDate = null;
                    _maxDate = null;
                  });
                },
                icon: Icon(LucideIcons.x, size: 14, color: Colors.red.shade400),
                label: Text('Clear date', style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ),
          const SizedBox(height: 24),

          /// Amount Filter
          Text(
            'Amount Range',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minController,
                  decoration: const InputDecoration(
                    labelText: 'Min Amount',
                    prefixText: '₹ ',
                    // border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxController,
                  decoration: const InputDecoration(
                    labelText: 'Max Amount',
                    prefixText: '₹ ',
                    // border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// Apply Button
          SizedBox(
            width: double.infinity,
            child: BouncingButton(
              child: ElevatedButton(
                onPressed: () {
                  final min = double.tryParse(_minController.text);
                  final max = double.tryParse(_maxController.text);

                  ref
                      .read(expenseFilterProvider.notifier)
                      .state = ExpenseFilter(
                    categories: _selectedCategories.isEmpty
                        ? null
                        : _selectedCategories,
                    minAmount: min,
                    maxAmount: max,
                    minDate: _minDate,
                    maxDate: _maxDate,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
