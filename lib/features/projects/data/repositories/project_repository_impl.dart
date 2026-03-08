import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_ds.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl(this.localDataSource);

  @override
  Future<void> addProject(Project project) async {
    final model = ProjectModel.fromEntity(project);
    await localDataSource.addProject(model);
  }

  @override
  Future<void> updateProject(Project project) async {
    final model = ProjectModel.fromEntity(
      project,
    ).copyWith(updatedAt: DateTime.now());
    await localDataSource.addProject(model);
  }

  @override
  Future<List<Project>> getProjects() async {
    final models = await localDataSource.getProjects();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteProject(String siteId) async {
    await localDataSource.deleteProject(siteId);
  }

  @override
  Future<List<Project>> getLocalChanges(DateTime? since) async {
    final models = await localDataSource.getLocalChanges(since);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> applyRemoteChanges(List<Project> changes) async {
    final models = changes.map((e) => ProjectModel.fromEntity(e)).toList();
    await localDataSource.applyRemoteChanges(models);
  }
}
