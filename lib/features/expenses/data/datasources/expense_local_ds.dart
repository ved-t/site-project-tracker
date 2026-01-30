import 'package:hive/hive.dart';
import '../../../../../../core/constants/hive_constants.dart';
import '../models/expense_model.dart';
import '../models/expense_hive_model.dart';

class ExpenseLocalDataSource {
  Future<Box> _openBox() async {
    return Hive.isBoxOpen(HiveBoxes.expenses)
        ? Hive.box(HiveBoxes.expenses)
        : await Hive.openBox(HiveBoxes.expenses);
  }

  Future<List<ExpenseModel>> getAll() async {
    final box = await _openBox();
    return box.values
        .map((e) {
          if (e is ExpenseHiveModel) {
            return ExpenseModel(
              id: e.id,
              siteId: e.siteId,
              title: e.title,
              amount: e.amount,
              date: e.date,
              category: e.category,
              vendor: e.vendor,
              remarks: e.remarks,
              createdAt: e.createdAt,
            );
          } else if (e is Map) {
            try {
              return ExpenseModel.fromJson(Map<String, dynamic>.from(e));
            } catch (err) {
              print('Error parsing legacy expense map: $err');
              return null;
            }
          }
          return null;
        })
        .whereType<ExpenseModel>()
        .toList();
  }

  Future<void> add(ExpenseModel model) async {
    final box = await _openBox();
    final hiveModel = ExpenseHiveModel(
      id: model.id,
      siteId: model.siteId,
      title: model.title,
      amount: model.amount,
      createdAt: model.createdAt,
      date: model.date,
      category: model.category,
      vendor: model.vendor,
      remarks: model.remarks,
    );
    await box.put(model.id, hiveModel);
  }

  Future<List<ExpenseModel>> getExpensesBySite(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((e) {
          if (e is ExpenseHiveModel) return e.siteId == siteId;
          if (e is Map)
            return e['site_id'] == siteId || e['projectId'] == siteId;
          return false;
        })
        .map((e) {
          if (e is ExpenseHiveModel) {
            return ExpenseModel(
              id: e.id,
              siteId: e.siteId,
              title: e.title,
              amount: e.amount,
              date: e.date,
              category: e.category,
              vendor: e.vendor,
              remarks: e.remarks,
              createdAt: e.createdAt,
            );
          } else if (e is Map) {
            try {
              return ExpenseModel.fromJson(Map<String, dynamic>.from(e));
            } catch (err) {
              return null;
            }
          }
          return null;
        })
        .whereType<ExpenseModel>()
        .toList();
  }

  Future<void> deleteExpenses(List<String> ids) async {
    final box = await _openBox();
    await box.deleteAll(ids);
  }
}
