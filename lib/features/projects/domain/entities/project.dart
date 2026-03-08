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

  Project copyWith({
    String? id,
    String? name,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? deviceId,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
