import '../entities/vendor.dart';
import '../repositories/vendor_repository.dart';

class GetVendors {
  final VendorRepository repository;

  GetVendors(this.repository);

  Future<List<Vendor>> call(String siteId) {
    return repository.getVendors(siteId);
  }
}
