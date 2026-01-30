import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<ExpenseCategoryEntity>> call(String siteId) {
    return repository.getCategories(siteId);
  }
}
