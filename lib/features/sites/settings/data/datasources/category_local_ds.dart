import 'package:hive/hive.dart';
import 'package:site_project_tracker/core/constants/hive_constants.dart';
import '../models/category_model.dart';
import '../models/category_hive_model.dart';

class CategoryLocalDataSource {
  Future<Box<CategoryHiveModel>> _openBox() async {
    return Hive.openBox<CategoryHiveModel>(HiveBoxes.categories);
  }

  Future<List<CategoryModel>> getBySite(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((c) => c.siteId == siteId)
        .map(
          (e) => CategoryModel(
            id: e.id,
            siteId: e.siteId,
            name: e.name,
            iconCodePoint: e.iconCodePoint,
            colorValue: e.color,
            createdAt: e.createdAt,
          ),
        )
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
    );
    await box.put(model.id, hiveModel);
  }

  Future<void> delete(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
