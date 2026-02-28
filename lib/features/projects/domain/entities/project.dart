class Project {
  final String id;
  final String name;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;

  Project({
    required this.id,
    required this.name,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
}
