import 'package:hive/hive.dart';
import 'package:site_project_tracker/core/constants/hive_constants.dart';
import '../models/category_model.dart';
import '../models/category_hive_model.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';

class CategoryLocalDataSource {
  final LocalStorageService storage;

  CategoryLocalDataSource(this.storage);

  Future<Box<CategoryHiveModel>> _openBox() async {
    return Hive.openBox<CategoryHiveModel>(HiveBoxes.categories);
  }

  Future<List<CategoryModel>> getBySite(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((c) => c.siteId == siteId && c.deletedAt == null)
        .map((e) => _toModel(e))
        .toList();
  }

  Future<void> upsert(CategoryModel model) async {
    final box = await _openBox();
    final hiveModel = CategoryHiveModel(
      id: model.id,
      siteId: model.siteId,
      name: model.name,
      iconCodePoint: model.iconCodePoint,
      color: model.colorValue,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      deviceId: model.deviceId,
    );

    await box.put(model.id, hiveModel);
  }

  Future<List<CategoryModel>> getLocalChanges(DateTime? since) async {
    final box = await _openBox();
    if (since == null) {
      return box.values.map((e) => _toModel(e)).toList();
    }
    return box.values
        .where(
          (e) => (e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(since),
        )
        .map((e) => _toModel(e))
        .toList();
  }

  Future<void> applyRemoteChanges(List<CategoryModel> changes) async {
    final box = await _openBox();
    for (var change in changes) {
      final hiveModel = CategoryHiveModel(
        id: change.id,
        siteId: change.siteId,
        name: change.name,
        iconCodePoint: change.iconCodePoint,
        color: change.colorValue,
        createdAt: change.createdAt,
        updatedAt: change.updatedAt,
        deletedAt: change.deletedAt,
        deviceId: change.deviceId,
      );

      await box.put(change.id, hiveModel);
    }
  }

  CategoryModel _toModel(CategoryHiveModel e) {
    return CategoryModel(
      id: e.id,
      siteId: e.siteId,
      name: e.name,
      iconCodePoint: e.iconCodePoint,
      colorValue: e.color,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt ?? e.createdAt,
      deletedAt: e.deletedAt,
      deviceId: e.deviceId,
    );
  }

  Future<void> delete(String id) async {
    final box = await _openBox();
    final existing = box.get(id);
    if (existing != null) {
      final updated = CategoryHiveModel(
        id: existing.id,
        siteId: existing.siteId,
        name: existing.name,
        iconCodePoint: existing.iconCodePoint,
        color: existing.color,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
        deviceId: existing.deviceId,
      );

      await box.put(id, updated);
    }
  }
}
