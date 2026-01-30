import '../entities/vendor.dart';
import '../repositories/vendor_repository.dart';

class UpdateVendor {
  final VendorRepository repository;

  UpdateVendor(this.repository);

  Future<void> call(Vendor vendor) {
    return repository.updateVendor(vendor);
  }
}
