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

  ProjectHiveModel({
    required this.id,
    required this.name,
    required this.location,
    required this.createdAt,
  });

  factory ProjectHiveModel.fromEntity(Project project) =>
      ProjectHiveModel(
        id: project.id,
        name: project.name,
        location: project.location,
        createdAt: project.createdAt,
      );

  Project toEntity() => Project(
        id: id,
        name: name,
        location: location,
        createdAt: createdAt,
      );
}
