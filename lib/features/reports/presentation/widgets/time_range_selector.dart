import 'package:flutter/material.dart';
import 'package:site_project_tracker/features/reports/domain/entities/date_range.dart';

class TimeRangeSelector extends StatefulWidget {
  final ValueChanged<DateRange> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.onChanged,
  });

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  int selectedIndex = 0;

  final labels = const [
    'This Month',
    'Last Month',
    'Last 7 Days',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (index) {
        return ChoiceChip(
          label: Text(labels[index]),
          selected: selectedIndex == index,
          onSelected: (_) {
            setState(() => selectedIndex = index);
            widget.onChanged(_rangeForIndex(index));
          },
        );
      }),
    );
  }

  DateRange _rangeForIndex(int index) {
    final now = DateTime.now();

    switch (index) {
      case 0: // This Month
        return DateRange(
          DateTime(now.year, now.month, 1),
          now,
        );

      case 1: // Last Month
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateRange(
          lastMonth,
          DateTime(now.year, now.month, 0),
        );

      case 2: // Last 7 Days
        return DateRange(
          now.subtract(const Duration(days: 7)),
          now,
        );

      default:
        return DateRange(now, now);
    }
  }
}
