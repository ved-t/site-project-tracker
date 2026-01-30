import '../repositories/vendor_repository.dart';

class DeleteVendor {
  final VendorRepository repository;

  DeleteVendor(this.repository);

  Future<void> call(String id) {
    return repository.deleteVendor(id);
  }
}
