import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_ds.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource local;

  CategoryRepositoryImpl(this.local);

  @override
  Future<List<ExpenseCategoryEntity>> getCategories(String siteId) async {
    final models = await local.getBySite(siteId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addCategory(ExpenseCategoryEntity category) async {
    await local.upsert(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> updateCategory(ExpenseCategoryEntity category) async {
    await local.upsert(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await local.delete(id);
  }
}
