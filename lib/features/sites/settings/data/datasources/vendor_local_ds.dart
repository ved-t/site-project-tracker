import 'package:hive/hive.dart';
import '../../../../../core/constants/hive_constants.dart';
import '../models/vendor_hive_model.dart';
import '../models/vendor_model.dart';
import 'package:site_project_tracker/core/services/local_storage_service.dart';

class VendorLocalDataSource {
  final LocalStorageService storage;
  VendorLocalDataSource(this.storage);

  Future<Box<VendorHiveModel>> _openBox() async {
    return Hive.isBoxOpen(HiveBoxes.vendors)
        ? Hive.box<VendorHiveModel>(HiveBoxes.vendors)
        : await Hive.openBox<VendorHiveModel>(HiveBoxes.vendors);
  }

  Future<List<VendorModel>> getBySite(String siteId) async {
    final box = await _openBox();
    return box.values
        .where((v) => v.siteId == siteId && v.deletedAt == null)
        .map((e) => VendorModel.fromEntity(e.toEntity()))
        .toList();
  }

  Future<void> upsert(VendorModel model) async {
    final hiveModel = VendorHiveModel(
      id: model.id,
      siteId: model.siteId,
      name: model.name,
      phone: model.phone,
      notes: model.notes,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: model.deletedAt,
      deviceId: model.deviceId,
    );

    final box = await _openBox();
    await box.put(model.id, hiveModel);
  }

  Future<List<VendorModel>> getLocalChanges(DateTime? since) async {
    final box = await _openBox();
    if (since == null) {
      return box.values
          .map((e) => VendorModel.fromEntity(e.toEntity()))
          .toList();
    }
    return box.values
        .where(
          (e) => (e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(since),
        )
        .map((e) => VendorModel.fromEntity(e.toEntity()))
        .toList();
  }

  Future<void> applyRemoteChanges(List<VendorModel> changes) async {
    for (var change in changes) {
      final hiveModel = VendorHiveModel(
        id: change.id,
        siteId: change.siteId,
        name: change.name,
        phone: change.phone,
        notes: change.notes,
        createdAt: change.createdAt,
        updatedAt: change.updatedAt,
        deletedAt: change.deletedAt,
        deviceId: change.deviceId,
      );

      final box = await _openBox();
      await box.put(change.id, hiveModel);
    }
  }

  Future<void> delete(String id) async {
    final box = await _openBox();
    final existing = box.get(id);
    if (existing != null) {
      final updated = VendorHiveModel(
        id: existing.id,
        siteId: existing.siteId,
        name: existing.name,
        phone: existing.phone,
        notes: existing.notes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
        deviceId: existing.deviceId,
      );

      await box.put(id, updated);
    }
  }
}
