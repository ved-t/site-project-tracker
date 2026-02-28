import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:site_project_tracker/core/services/sync_manager.dart';
import 'package:site_project_tracker/core/services/sync_remote_data_source.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';
import 'package:site_project_tracker/core/utils/logger.dart';
import '../network/dio_log_interceptor.dart';

// Imports for repositories
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/data/datasources/project_local_ds.dart';
import '../../features/sites/settings/data/datasources/category_local_ds.dart';
import '../../features/sites/settings/data/repositories/category_repository_impl.dart';
import '../../features/sites/settings/data/datasources/vendor_local_ds.dart';
import '../../features/sites/settings/data/repositories/vendor_repository_impl.dart';
import '../../features/expenses/data/datasources/expense_local_ds.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';

// Placeholder for Dio. Should be configured with correct BaseURL and Interceptors.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.9:8000',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  dio.interceptors.add(DioLogInterceptor());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.debug(
          '🌐 [DIO] REQUEST[${options.method}] => PATH: ${options.path}',
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.debug(
          '✅ [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        AppLogger.error(
          '❌ [DIO] ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          error: e,
        );
        return handler.next(e);
      },
    ),
  );

  return dio;
});

final syncRemoteDataSourceProvider = Provider((ref) {
  // Use the same base URL as Dio, or distinct if needed.
  // Since SyncRemoteDataSource appends baseUrl, let's keep it consistent.
  return SyncRemoteDataSource(
    dio: ref.read(dioProvider),
    baseUrl: 'http://192.168.1.9:8000',
  );
});

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final projectRepositoryProvider = Provider(
  (ref) => ProjectRepositoryImpl(
    ProjectLocalDataSourceImpl(ref.read(localStorageServiceProvider)),
  ),
);

final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepositoryImpl(
    CategoryLocalDataSource(ref.read(localStorageServiceProvider)),
  ),
);

final vendorRepositoryProvider = Provider(
  (ref) => VendorRepositoryImpl(
    VendorLocalDataSource(ref.read(localStorageServiceProvider)),
  ),
);

final expenseRepositoryProvider = Provider(
  (ref) => ExpenseRepositoryImpl(
    ExpenseLocalDataSource(ref.read(localStorageServiceProvider)),
  ),
);

final syncManagerProvider = Provider((ref) {
  return SyncManager(
    projectRepo: ref.read(projectRepositoryProvider),
    categoryRepo: ref.read(categoryRepositoryProvider),
    vendorRepo: ref.read(vendorRepositoryProvider),
    expenseRepo: ref.read(expenseRepositoryProvider),
    remote: ref.read(syncRemoteDataSourceProvider),
    storage: ref.read(localStorageServiceProvider),
  );
});
