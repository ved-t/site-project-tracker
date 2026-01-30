import '../repositories/project_repository.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';

class DeleteProject {
  final ProjectRepository projectRepository;
  final ExpenseRepository expenseRepository;

  DeleteProject({
    required this.projectRepository,
    required this.expenseRepository,
  });

  Future<void> call(String siteId) async {
    // 1. Delete all expenses for this site
    await expenseRepository.deleteExpensesBySite(siteId);

    // 2. Delete the project/site itself
    await projectRepository.deleteProject(siteId);
  }
}
