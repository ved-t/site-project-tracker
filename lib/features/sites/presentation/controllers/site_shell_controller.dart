import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/domain/entities/expense.dart';

/// Controls the currently selected bottom-navigation tab index inside SiteShellScreen.
final siteShellTabIndexProvider = StateProvider<int>((ref) => 0);

/// Holds the expense that is currently being edited, or null when adding a new expense.
final editingExpenseProvider = StateProvider<Expense?>((ref) => null);
