import 'package:hive/hive.dart';
import '../../../../../core/constants/hive_constants.dart';
import '../models/vendor_hive_model.dart';
import '../models/vendor_model.dart';

class VendorLocalDataSource {
  final Box box = Hive.box(HiveBoxes.vendors);

  List<VendorModel> getBySite(String siteId) {
    return box.values
        .cast<VendorHiveModel>()
        .where((v) => v.siteId == siteId)
        .map((e) => VendorModel.fromEntity(e.toEntity()))
        .toList();
  }

  Future<void> upsert(VendorModel model) async {
    final hiveModel = VendorHiveModel.fromEntity(model.toEntity());
    await box.put(model.id, hiveModel);
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
