import 'package:site_project_tracker/core/services/sync_remote_data_source.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';
import 'package:site_project_tracker/features/sites/settings/domain/repositories/category_repository.dart';
import 'package:site_project_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:site_project_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:site_project_tracker/features/sites/settings/domain/repositories/vendor_repository.dart';
import 'package:site_project_tracker/features/projects/data/models/project_model.dart';
import 'package:site_project_tracker/features/expenses/data/models/expense_model.dart';
import 'package:site_project_tracker/features/sites/settings/data/models/category_model.dart';
import 'package:site_project_tracker/features/sites/settings/data/models/vendor_model.dart';
import 'package:site_project_tracker/core/utils/logger.dart';

import 'package:dio/dio.dart';
import 'package:site_project_tracker/core/utils/toast_utils.dart';

class SyncManager {
  final ProjectRepository projectRepo;
  final CategoryRepository categoryRepo;
  final VendorRepository vendorRepo;
  final ExpenseRepository expenseRepo;

  final SyncRemoteDataSource remote;
  final LocalStorageService storage;

  bool _isSyncing = false;

  SyncManager({
    required this.projectRepo,
    required this.categoryRepo,
    required this.vendorRepo,
    required this.expenseRepo,
    required this.remote,
    required this.storage,
  });

  Future<bool> sync() async {
    if (_isSyncing) {
      AppLogger.sync('Sync already in progress, skipping...');
      return false;
    }
    _isSyncing = true;
    AppLogger.sync('Starting synchronization process...');

    try {
      final deviceId = await storage.getDeviceId();
      var lastSyncAt = await storage.getLastSyncAt();
      AppLogger.sync(
        'Starting sync for device: $deviceId. Local last sync: ${lastSyncAt?.toIso8601String() ?? 'Never'}',
      );

      // 0️⃣ Check remote last sync time
      AppLogger.sync('Fetching remote last sync time for device: $deviceId');
      final remoteSyncData = await remote.getDeviceLastSync(deviceId);

      if (remoteSyncData != null) {
        final remoteLastSync = remoteSyncData.lastSyncAt;
        AppLogger.sync(
          'Remote last sync time: ${remoteLastSync.toIso8601String()}',
        );

        if (lastSyncAt == null ||
            !lastSyncAt.isAtSameMomentAs(remoteLastSync)) {
          AppLogger.warning('Sync timestamp discrepancy detected!');
          AppLogger.sync(
            'Updating local last sync to match remote: ${remoteLastSync.toIso8601String()}',
          );
          await storage.setLastSyncAt(remoteLastSync);
          lastSyncAt = remoteLastSync;
        } else {
          AppLogger.sync('Local and remote timestamps match.');
        }
      } else {
        AppLogger.sync(
          'No remote sync history found for this device. Setting last sync to epoch.',
        );
        final epoch = DateTime.fromMillisecondsSinceEpoch(0);
        await storage.setLastSyncAt(epoch);
        lastSyncAt = epoch;
      }

      // 1️⃣ Collect local changes
      final sites = await projectRepo.getLocalChanges(lastSyncAt);
      final categories = await categoryRepo.getLocalChanges(lastSyncAt);
      final vendors = await vendorRepo.getLocalChanges(lastSyncAt);
      final expenses = await expenseRepo.getLocalChanges(lastSyncAt);

      AppLogger.sync(
        'Local changes collected: '
        '${sites.length} sites, '
        '${categories.length} categories, '
        '${vendors.length} vendors, '
        '${expenses.length} expenses',
      );

      final localData = {
        "sites": sites.map((e) => ProjectModel.fromEntity(e).toJson()).toList(),
        "categories": categories
            .map((e) => CategoryModel.fromEntity(e).toJson())
            .toList(),
        "vendors": vendors
            .map((e) => VendorModel.fromEntity(e).toJson())
            .toList(),
        "expenses": expenses
            .map((e) => ExpenseModel.fromEntity(e).toJson())
            .toList(),
      };

      // 2️⃣ PUSH
      AppLogger.sync('Pushing local changes to remote...');
      final pushResponse = await remote.push(
        deviceId: deviceId,
        data: localData,
      );
      AppLogger.sync(
        'Push completed. Success: ${pushResponse.success}. '
        'Synced counts: ${pushResponse.syncedCount}',
      );

      // 3️⃣ PULL
      AppLogger.sync('Pulling changes from remote...');
      final response = await remote.pull(deviceId: deviceId, since: lastSyncAt);
      AppLogger.sync(
        'Pull completed. Remote changes found: '
        '${response.sites.length} sites, '
        '${response.categories.length} categories, '
        '${response.vendors.length} vendors, '
        '${response.expenses.length} expenses',
      );

      // 4️⃣ Apply remote changes
      await projectRepo.applyRemoteChanges(
        response.sites.map((e) => e.toEntity()).toList(),
      );
      await categoryRepo.applyRemoteChanges(
        response.categories.map((e) => e.toEntity()).toList(),
      );
      await vendorRepo.applyRemoteChanges(
        response.vendors.map((e) => e.toEntity()).toList(),
      );
      await expenseRepo.applyRemoteChanges(
        response.expenses.map((e) => e.toEntity()).toList(),
      );
      AppLogger.sync('Remote changes applied locally.');

      // 5️⃣ Update sync time
      await storage.setLastSyncAt(response.timestamp);
      AppLogger.sync('Sync completed successfully at ${response.timestamp}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Sync failed',
        error: e,
        stackTrace: stackTrace,
        name: 'SYNC',
      );

      if (e is DioException) {
        if (e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionTimeout) {
          ToastUtils.show(
            'Server connection timed out. Please try again later.',
            isError: true,
          );
        } else {
          ToastUtils.show('Sync error: ${e.message}', isError: true);
        }
      } else {
        ToastUtils.show('Sync failed: $e', isError: true);
      }
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
