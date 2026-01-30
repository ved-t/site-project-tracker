import '../entities/project.dart';

abstract class ProjectRepository {
  Future<void> addProject(Project project);
  Future<List<Project>> getProjects();
  Future<void> deleteProject(String siteId);
}
