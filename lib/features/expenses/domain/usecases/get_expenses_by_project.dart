import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByProject {
  final ExpenseRepository repository;

  GetExpensesByProject(this.repository);

  Future<List<Expense>> call(String siteId) {
    return repository.getExpensesBySite(siteId);
  }
}
