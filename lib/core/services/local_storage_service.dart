import 'package:hive_flutter/hive_flutter.dart';
import '../../features/expenses/data/models/expense_hive_model.dart';
import '../../features/projects/data/models/project_hive_model.dart';
import '../../features/sites/settings/data/models/vendor_hive_model.dart';
import '../../features/sites/settings/data/models/category_hive_model.dart';
import '../../features/sites/settings/formulas/data/models/formula_hive_model.dart';
import '../constants/hive_constants.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectHiveModelAdapter());
    Hive.registerAdapter(ExpenseHiveModelAdapter());
    Hive.registerAdapter(VendorHiveModelAdapter());
    Hive.registerAdapter(CategoryHiveModelAdapter());
    Hive.registerAdapter(FormulaHiveModelAdapter());
    await Hive.openBox(HiveBoxes.expenses);
    await Hive.openBox(HiveBoxes.vendors);
  }
}
