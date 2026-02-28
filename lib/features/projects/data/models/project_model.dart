// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/project.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

@freezed
class ProjectModel with _$ProjectModel {
  const ProjectModel._(); // custom methods

  const factory ProjectModel({
    required String id,
    required String name,
    required String location,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @JsonKey(name: 'device_id') required String deviceId,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  factory ProjectModel.fromEntity(Project project) => ProjectModel(
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
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    deviceId: deviceId,
  );
}
