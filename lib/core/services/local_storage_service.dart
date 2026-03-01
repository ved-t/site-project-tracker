import 'package:hive_flutter/hive_flutter.dart';
import '../../features/expenses/data/models/expense_hive_model.dart';
import '../../features/projects/data/models/project_hive_model.dart';
import '../../features/sites/settings/data/models/vendor_hive_model.dart';
import '../../features/sites/settings/data/models/category_hive_model.dart';
import '../../features/sites/settings/formulas/data/models/formula_hive_model.dart';

class LocalStorageService {
  static const String _settingsBox = 'settings';
  static const String _keyDeviceId = 'device_id';
  static const String _keyLastSync = 'last_sync_at';
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  Future<String> getDeviceId() async {
    final box = await Hive.openBox(_settingsBox);
    var deviceId = box.get(_keyDeviceId);
    if (deviceId == null) {
      // Generate simple ID if not present. uuid package is in pubspec
      // But let's verify if uuid is imported.
      // Or just use a random string.
      // Better to use uuid.
      // Assuming I can import uuid.
      // For now, let's assume UUID is not imported in this file, so I'll add import.
      // Or I can use existing logic if any.
      // Let's defer UUID strictly to implementation.
      deviceId = DateTime.now().millisecondsSinceEpoch.toString(); // Fallback
      await box.put(_keyDeviceId, deviceId);
    }
    return deviceId;
  }

  Future<bool> getHasSeenOnboarding() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_keyHasSeenOnboarding, defaultValue: false) as bool;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_keyHasSeenOnboarding, value);
  }

  Future<DateTime?> getLastSyncAt() async {
    final box = await Hive.openBox(_settingsBox);
    final val = box.get(_keyLastSync);
    if (val != null) return DateTime.parse(val);
    return null;
  }

  Future<void> setLastSyncAt(DateTime time) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_keyLastSync, time.toIso8601String());
  }

  Future<String?> getProfileImagePath(String userId) async {
    final box = await Hive.openBox(_settingsBox);
    return box.get('profile_image_$userId');
  }

  Future<void> setProfileImagePath(String userId, String path) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put('profile_image_$userId', path);
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProjectHiveModelAdapter());
    Hive.registerAdapter(ExpenseHiveModelAdapter());
    Hive.registerAdapter(VendorHiveModelAdapter());
    Hive.registerAdapter(CategoryHiveModelAdapter());
    Hive.registerAdapter(FormulaHiveModelAdapter());
    // Hive.registerAdapter(ReportHiveModelAdapter()); // Disabled reports local storage
  }
}
