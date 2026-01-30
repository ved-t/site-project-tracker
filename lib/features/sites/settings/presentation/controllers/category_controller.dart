import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../../data/datasources/category_local_ds.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

final categoryLocalDsProvider = Provider((_) => CategoryLocalDataSource());

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryLocalDsProvider)),
);

final getCategoriesProvider = Provider(
  (ref) => GetCategories(ref.read(categoryRepositoryProvider)),
);

final addCategoryProvider = Provider(
  (ref) => AddCategory(ref.read(categoryRepositoryProvider)),
);

final updateCategoryProvider = Provider(
  (ref) => UpdateCategory(ref.read(categoryRepositoryProvider)),
);

final deleteCategoryProvider = Provider(
  (ref) => DeleteCategory(ref.read(categoryRepositoryProvider)),
);

final categoriesProvider =
    StateNotifierProvider.family<
      CategoryController,
      List<ExpenseCategoryEntity>,
      String
    >((ref, siteId) {
      return CategoryController(
        ref.read(getCategoriesProvider),
        ref.read(addCategoryProvider),
        ref.read(updateCategoryProvider),
        ref.read(deleteCategoryProvider),
        siteId,
      );
    });

class CategoryController extends StateNotifier<List<ExpenseCategoryEntity>> {
  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final String siteId;

  CategoryController(
    this._getCategories,
    this._addCategory,
    this._updateCategory,
    this._deleteCategory,
    this.siteId,
  ) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _getCategories(siteId);

    if (state.isEmpty) {
      await _seedDefaultCategories();
      state = await _getCategories(siteId);
    }
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      _createDefault('Labor', Icons.engineering, Colors.orange),
      _createDefault('Materials', Icons.construction, Colors.blue),
      _createDefault('Transportation', Icons.local_shipping, Colors.blueGrey),
      _createDefault('Permits', Icons.receipt_long, Colors.purple),
      _createDefault('Rentals', Icons.handyman, Colors.teal),
      _createDefault('Food / Snacks', Icons.fastfood, Colors.red),
      _createDefault(
        'Miscellaneous',
        Icons.miscellaneous_services,
        Colors.grey,
      ),
    ];

    for (final cat in defaults) {
      await _addCategory(cat);
    }
  }

  ExpenseCategoryEntity _createDefault(
    String name,
    IconData icon,
    Color color,
  ) {
    return ExpenseCategoryEntity(
      id: const Uuid().v4(),
      siteId: siteId,
      name: name,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
    );
  }

  Future<void> save(ExpenseCategoryEntity category) async {
    final exists = state.any((e) => e.id == category.id);
    if (exists) {
      await _updateCategory(category);
    } else {
      await _addCategory(category);
    }
    await load();
  }

  Future<void> delete(String id) async {
    await _deleteCategory(id);
    await load();
  }
}
