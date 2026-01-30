class Vendor {
  final String id;
  final String siteId;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  Vendor({
    required this.id,
    required this.siteId,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });
}
