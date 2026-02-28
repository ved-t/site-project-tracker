import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/core/services/sync_providers.dart';
import 'package:site_project_tracker/core/services/sync_manager.dart';

import '../../domain/entities/vendor.dart';
import '../../domain/usecases/add_vendor.dart';
import '../../domain/usecases/delete_vendor.dart';
import '../../domain/usecases/get_vendors.dart';
import '../../domain/usecases/update_vendor.dart';

final getVendorsProvider = Provider(
  (ref) => GetVendors(ref.read(vendorRepositoryProvider)),
);

final addVendorProvider = Provider(
  (ref) => AddVendor(ref.read(vendorRepositoryProvider)),
);

final updateVendorProvider = Provider(
  (ref) => UpdateVendor(ref.read(vendorRepositoryProvider)),
);

final deleteVendorProvider = Provider(
  (ref) => DeleteVendor(ref.read(vendorRepositoryProvider)),
);

final vendorsProvider =
    StateNotifierProvider.family<VendorController, List<Vendor>, String>((
      ref,
      siteId,
    ) {
      return VendorController(
        ref.read(getVendorsProvider),
        ref.read(addVendorProvider),
        ref.read(updateVendorProvider),
        ref.read(deleteVendorProvider),
        ref.read(syncManagerProvider),
        siteId,
      );
    });

class VendorController extends StateNotifier<List<Vendor>> {
  final GetVendors _getVendors;
  final AddVendor _addVendor;
  final UpdateVendor _updateVendor;
  final DeleteVendor _deleteVendor;
  final SyncManager _syncManager;
  final String siteId;

  VendorController(
    this._getVendors,
    this._addVendor,
    this._updateVendor,
    this._deleteVendor,
    this._syncManager,
    this.siteId,
  ) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _getVendors(siteId);
  }

  Future<void> save(Vendor vendor) async {
    final exists = state.any((e) => e.id == vendor.id);
    if (exists) {
      await _updateVendor(vendor);
    } else {
      await _addVendor(vendor);
    }
    await load();
    await _syncManager.sync();
  }

  Future<void> delete(String id) async {
    await _deleteVendor(id);
    await load();
    await _syncManager.sync();
  }
}
