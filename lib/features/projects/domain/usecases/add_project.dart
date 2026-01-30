import '../entities/project.dart';
import '../repositories/project_repository.dart';

class AddProject {
  final ProjectRepository repository;

  AddProject(this.repository);

  Future<void> call(Project project) {
    return repository.addProject(project);
  }
}
