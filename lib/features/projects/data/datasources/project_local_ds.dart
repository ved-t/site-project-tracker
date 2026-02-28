import 'package:hive/hive.dart';
import '../models/project_hive_model.dart';
import '../models/project_model.dart';

import 'package:site_project_tracker/core/services/local_storage_service.dart';

abstract class ProjectLocalDataSource {
  Future<void> deleteProject(String siteId);
  Future<List<ProjectModel>> getLocalChanges(DateTime? since);
  Future<void> addProject(ProjectModel project);
  Future<void> applyRemoteChanges(List<ProjectModel> changes);
  Future<List<ProjectModel>> getProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  static const String boxName = 'projects';
  final LocalStorageService storage;

  ProjectLocalDataSourceImpl(this.storage);

  Future<Box<ProjectHiveModel>> _openBox() async {
    return Hive.openBox<ProjectHiveModel>(boxName);
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    final box = await _openBox();
    final hiveModel = ProjectHiveModel(
      id: project.id,
      name: project.name,
      location: project.location,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      deletedAt: project.deletedAt,
      deviceId: project.deviceId,
    );

    await box.put(project.id, hiveModel);
  }

  @override
  Future<List<ProjectModel>> getLocalChanges(DateTime? since) async {
    final box = await _openBox();
    if (since == null) {
      return box.values.map((e) => _toModel(e)).toList();
    }
    return box.values
        .where(
          (e) => (e.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(since),
        )
        .map((e) => _toModel(e))
        .toList();
  }

  @override
  Future<void> applyRemoteChanges(List<ProjectModel> changes) async {
    final box = await _openBox();
    for (var change in changes) {
      // Last Write Wins or Server Wins logic could go here,
      // but typically we just overwrite local if server sent it
      // Check if local is newer?
      // For now, overwrite
      final hiveModel = ProjectHiveModel(
        id: change.id,
        name: change.name,
        location: change.location,
        createdAt: change.createdAt,
        updatedAt: change.updatedAt,
        deletedAt: change.deletedAt,
        deviceId: change.deviceId,
      );

      await box.put(change.id, hiveModel);
    }
  }

  ProjectModel _toModel(ProjectHiveModel e) {
    return ProjectModel(
      id: e.id,
      name: e.name,
      location: e.location,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt ?? e.createdAt,
      deletedAt: e.deletedAt,
      deviceId: e.deviceId,
    );
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final box = await _openBox();
    return box.values
        .where((e) => e.deletedAt == null) // Filter out soft deleted
        .map((e) => _toModel(e))
        .toList();
  }

  @override
  Future<void> deleteProject(String siteId) async {
    final box = await _openBox();
    final existing = box.get(siteId);
    if (existing != null) {
      // Soft delete
      final updated = ProjectHiveModel(
        id: existing.id,
        name: existing.name,
        location: existing.location,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
        deviceId: existing.deviceId,
      );

      await box.put(siteId, updated);
    }
  }
}
