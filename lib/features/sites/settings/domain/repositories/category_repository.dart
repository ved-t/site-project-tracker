import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<ExpenseCategoryEntity>> getCategories(String siteId);
  Future<void> addCategory(ExpenseCategoryEntity category);
  Future<void> updateCategory(ExpenseCategoryEntity category);
  Future<void> deleteCategory(String id);
}
