import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:site_project_tracker/core/services/sync_manager.dart';
import '../../../../../core/utils/dio_error_handler.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../core/utils/logger.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

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
        ref.read(localStorageServiceProvider),
        ref.read(syncManagerProvider),
        siteId,
      );
    });

class CategoryController extends StateNotifier<List<ExpenseCategoryEntity>> {
  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final LocalStorageService _localStorageService;
  final SyncManager _syncManager;
  final String siteId;

  CategoryController(
    this._getCategories,
    this._addCategory,
    this._updateCategory,
    this._deleteCategory,
    this._localStorageService,
    this._syncManager,
    this.siteId,
  ) : super([]) {
    load();
  }

  Future<void> load() async {
    try {
      state = await _getCategories(siteId);

      if (state.isEmpty) {
        await _seedDefaultCategories();
        state = await _getCategories(siteId);
      }
    } catch (e) {
      AppLogger.error('Failed to load categories', error: e, name: 'CAT_CTRL');
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> _seedDefaultCategories() async {
    final deviceId = await _localStorageService.getDeviceId();
    final defaults = [
      _createDefault('Labor', Icons.engineering, Colors.orange, deviceId),
      _createDefault('Materials', Icons.construction, Colors.blue, deviceId),
      _createDefault(
        'Transportation',
        Icons.local_shipping,
        Colors.blueGrey,
        deviceId,
      ),
      _createDefault('Permits', Icons.receipt_long, Colors.purple, deviceId),
      _createDefault('Rentals', Icons.handyman, Colors.teal, deviceId),
      _createDefault('Food / Snacks', Icons.fastfood, Colors.red, deviceId),
      _createDefault(
        'Miscellaneous',
        Icons.miscellaneous_services,
        Colors.grey,
        deviceId,
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
    String deviceId,
  ) {
    return ExpenseCategoryEntity(
      id: const Uuid().v4(),
      siteId: siteId,
      name: name,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );
  }

  Future<void> save(ExpenseCategoryEntity category) async {
    try {
      final exists = state.any((e) => e.id == category.id);
      if (exists) {
        await _updateCategory(category);
      } else {
        await _addCategory(category);
      }
      await load();
      await _syncManager.sync();
    } catch (e) {
      AppLogger.error('Failed to save category', error: e, name: 'CAT_CTRL');
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteCategory(id);
      await load();
      await _syncManager.sync();
    } catch (e) {
      AppLogger.error('Failed to delete category', error: e, name: 'CAT_CTRL');
      final msg = DioErrorHandler.getErrorMessage(e);
      ToastUtils.show(msg, isError: true);
    }
  }
}
