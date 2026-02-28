import '../entities/project.dart';

abstract class ProjectRepository {
  Future<void> addProject(Project project);
  Future<List<Project>> getProjects();
  Future<void> deleteProject(String siteId);
  Future<List<Project>> getLocalChanges(DateTime? since);
  Future<void> applyRemoteChanges(List<Project> changes);
}
