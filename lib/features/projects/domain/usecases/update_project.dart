import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProject {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  Future<void> call(Project project) {
    return repository.updateProject(project);
  }
}
