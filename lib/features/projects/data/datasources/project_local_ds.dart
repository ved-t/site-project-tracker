import 'package:hive/hive.dart';
import '../models/project_hive_model.dart';
import '../models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<void> addProject(ProjectModel project);
  Future<List<ProjectModel>> getProjects();
  Future<void> deleteProject(String siteId);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  static const String boxName = 'projects';

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
    );
    await box.put(project.id, hiveModel);
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final box = await _openBox();
    return box.values
        .map(
          (e) => ProjectModel(
            id: e.id,
            name: e.name,
            location: e.location,
            createdAt: e.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteProject(String siteId) async {
    final box = await _openBox();
    await box.delete(siteId);
  }
}
