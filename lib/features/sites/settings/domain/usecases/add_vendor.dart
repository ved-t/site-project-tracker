import '../entities/vendor.dart';
import '../repositories/vendor_repository.dart';

class AddVendor {
  final VendorRepository repository;

  AddVendor(this.repository);

  Future<void> call(Vendor vendor) {
    return repository.addVendor(vendor);
  }
}
