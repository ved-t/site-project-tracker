import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(expenseFilterProvider);
    _selectedCategories = List.from(currentFilter.categories ?? []);
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
          Wrap(
            spacing: 8,
            children: availableCategories.map((category) {
              final isSelected = _selectedCategories.contains(category.name);
              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => _toggleCategory(category.name),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
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
