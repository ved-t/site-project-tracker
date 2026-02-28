import 'package:hive/hive.dart';
import '../../domain/entities/project.dart';

part 'project_hive_model.g.dart';

@HiveType(typeId: 1)
class ProjectHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  @HiveField(5)
  final DateTime? deletedAt;

  @HiveField(6)
  final String deviceId;

  ProjectHiveModel({
    required this.id,
    required this.name,
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });

  factory ProjectHiveModel.fromEntity(Project project) => ProjectHiveModel(
    id: project.id,
    name: project.name,
    location: project.location,
    createdAt: project.createdAt,
    updatedAt: project.updatedAt,
    deletedAt: project.deletedAt,
    deviceId: project.deviceId,
  );

  Project toEntity() => Project(
    id: id,
    name: name,
    location: location,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
