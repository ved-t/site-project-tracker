import '../entities/vendor.dart';

abstract class VendorRepository {
  Future<List<Vendor>> getVendors(String siteId);
  Future<void> addVendor(Vendor vendor);
  Future<void> updateVendor(Vendor vendor);
  Future<void> deleteVendor(String id);
}
