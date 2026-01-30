import 'package:site_project_tracker/features/categories/data/repositories/category_repository.dart';
import 'package:site_project_tracker/features/expenses/data/repositories/expense_repository.dart';
import 'package:site_project_tracker/features/projects/data/repositories/project_repository.dart';
import 'package:site_project_tracker/features/vendors/data/repositories/vendor_repository.dart';

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

  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final deviceId = await storage.getDeviceId();
      final lastSyncAt = await storage.getLastSyncAt();

      // 1️⃣ Collect local changes
      final localData = {
        "sites": await projectRepo.getLocalChanges(lastSyncAt),
        "categories": await categoryRepo.getLocalChanges(lastSyncAt),
        "vendors": await vendorRepo.getLocalChanges(lastSyncAt),
        "expenses": await expenseRepo.getLocalChanges(lastSyncAt),
      };

      // 2️⃣ PUSH
      await remote.push(
        deviceId: deviceId,
        data: localData,
      );

      // 3️⃣ PULL
      final response = await remote.pull(
        deviceId: deviceId,
        since: lastSyncAt,
      );

      // 4️⃣ Apply remote changes
      await projectRepo.applyRemoteChanges(response.sites);
      await categoryRepo.applyRemoteChanges(response.categories);
      await vendorRepo.applyRemoteChanges(response.vendors);
      await expenseRepo.applyRemoteChanges(response.expenses);

      // 5️⃣ Update sync time
      await storage.setLastSyncAt(response.timestamp);
    } finally {
      _isSyncing = false;
    }
  }
}
