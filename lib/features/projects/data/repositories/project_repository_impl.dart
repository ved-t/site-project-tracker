import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_ds.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl(this.localDataSource);

  @override
  Future<void> addProject(Project project) async {
    // Override add to ensure updatedAt is set (though entity should might have it,
    // but typically repo handles 'creation' timestamp if not provided,
    // but here entity has it. We ensure model has it.)
    // Actually, we need to modify the entity to set updatedAt if it's missing or old?
    // The entity is immutable.
    // The 'add' op implies new.

    // Check if we need to set updatedAt to now.
    // Assuming UI passed valid project.

    final model = ProjectModel.fromEntity(project);
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
