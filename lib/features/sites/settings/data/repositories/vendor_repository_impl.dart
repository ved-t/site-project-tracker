import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_local_ds.dart';
import '../models/vendor_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorLocalDataSource local;

  VendorRepositoryImpl(this.local);

  @override
  Future<List<Vendor>> getVendors(String siteId) async {
    final models = await local.getBySite(siteId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addVendor(Vendor vendor) async {
    await local.upsert(VendorModel.fromEntity(vendor));
  }

  @override
  Future<void> updateVendor(Vendor vendor) async {
    await local.upsert(VendorModel.fromEntity(vendor));
  }

  @override
  Future<void> deleteVendor(String id) async {
    await local.delete(id);
  }

  @override
  Future<List<Vendor>> getLocalChanges(DateTime? since) async {
    final models = await local.getLocalChanges(since);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> applyRemoteChanges(List<Vendor> changes) async {
    final models = changes.map((e) => VendorModel.fromEntity(e)).toList();
    await local.applyRemoteChanges(models);
  }
}
