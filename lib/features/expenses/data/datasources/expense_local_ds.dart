import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../models/expense_model.dart';
import '../models/expense_hive_model.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';

class ExpenseLocalDataSource {
  final LocalStorageService storage;

  ExpenseLocalDataSource(this.storage);

  Future<Box> _openBox() async {
    return Hive.isBoxOpen(HiveBoxes.expenses)
        ? Hive.box(HiveBoxes.expenses)
        : await Hive.openBox(HiveBoxes.expenses);
  }

  Future<List<ExpenseModel>> getAll() async {
    final box = await _openBox();
    return box.values
        .where((e) {
          if (e is ExpenseHiveModel) return e.deletedAt == null;
          // Legacy map support - assume not deleted if map? or filter?
          // Legacy maps don't have deletedAt, so they are not deleted.
          return true;
        })
        .map((e) {
          if (e is ExpenseHiveModel) {
            return _toModel(e);
          } else if (e is Map) {
            try {
              final map = Map<String, dynamic>.from(e);
              // Backfill required fields for legacy data
              if (map['createdAt'] == null) {
                map['createdAt'] = DateTime.now().toIso8601String();
              }
              if (map['device_id'] == null) {
                map['device_id'] = 'unknown_legacy_device';
              }

              return ExpenseModel.fromJson(map);
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
      updatedAt: model.updatedAt,
      date: model.date,
      categoryId: model.categoryId,
      vendor: model.vendor,
      remarks: model.remarks,
      deviceId: model.deviceId,
    );

    await box.put(model.id, hiveModel);
  }

  Future<void> saveExpense(ExpenseModel model) async {
    final box = await _openBox();
    final hiveModel = ExpenseHiveModel(
      id: model.id,
      siteId: model.siteId,
      title: model.title,
      amount: model.amount,
      createdAt: model.createdAt,
      date: model.date,
      categoryId: model.categoryId,
      vendor: model.vendor,
      remarks: model.remarks,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      deviceId: model.deviceId,
    );

    await box.put(model.id, hiveModel);
  }

  Future<List<ExpenseModel>> getLocalChanges(DateTime? since) async {
    final box = await _openBox();
    if (since == null) {
      return box.values
          .whereType<ExpenseHiveModel>()
          .map((e) => _toModel(e))
          .toList();
    }
    return box.values
        .whereType<ExpenseHiveModel>()
        .where(
          (e) => (e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(since),
        )
        .map((e) => _toModel(e))
        .toList();
  }

  Future<void> applyRemoteChanges(List<ExpenseModel> changes) async {
    final box = await _openBox();
    for (var change in changes) {
      final hiveModel = ExpenseHiveModel(
        id: change.id,
        siteId: change.siteId,
        title: change.title,
        amount: change.amount,
        createdAt: change.createdAt,
        date: change.date,
        categoryId: change.categoryId,
        vendor: change.vendor,
        remarks: change.remarks,
        updatedAt: change.updatedAt,
        deletedAt: change.deletedAt,
        deviceId: change.deviceId,
      );

      await box.put(change.id, hiveModel);
    }
  }

  ExpenseModel _toModel(ExpenseHiveModel e) {
    return ExpenseModel(
      id: e.id,
      siteId: e.siteId,
      title: e.title,
      amount: e.amount,
      date: e.date,
      categoryId: e.categoryId,
      vendor: e.vendor,
      remarks: e.remarks,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt ?? e.createdAt,
      deletedAt: e.deletedAt,
      deviceId: e.deviceId,
    );
  }

  Future<List<ExpenseModel>> getExpensesBySite(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((e) {
          if (e is ExpenseHiveModel)
            return e.siteId == siteId && e.deletedAt == null;
          if (e is Map)
            return e['site_id'] == siteId || e['projectId'] == siteId;
          return false;
        })
        .map((e) {
          if (e is ExpenseHiveModel) {
            return _toModel(e);
          } else if (e is Map) {
            try {
              final map = Map<String, dynamic>.from(e);
              if (map['createdAt'] == null) {
                map['createdAt'] = DateTime.now().toIso8601String();
              }
              if (map['device_id'] == null) {
                map['device_id'] = 'unknown_legacy_device';
              }
              return ExpenseModel.fromJson(map);
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
    for (var id in ids) {
      final existing = box.get(id);
      if (existing is ExpenseHiveModel) {
        // Soft delete
        // We need to re-save with deletedAt
        // Since Hive objects are mutable if we extend HiveObject, we could strictly modify fields?
        // But here we reconstruct.

        final updated = ExpenseHiveModel(
          id: existing.id,
          siteId: existing.siteId,
          title: existing.title,
          amount: existing.amount,
          createdAt: existing.createdAt,
          date: existing.date,
          categoryId: existing.categoryId,
          vendor: existing.vendor,
          remarks: existing.remarks,
          updatedAt: DateTime.now(),
          deletedAt: DateTime.now(),
          deviceId: existing.deviceId,
        );

        await box.put(id, updated);
      } else {
        // Fallback for legacy or if map?
        // If map, maybe just delete? Or simple soft delete not supported for legacy maps.
        await box.delete(id);
      }
    }
  }
}
