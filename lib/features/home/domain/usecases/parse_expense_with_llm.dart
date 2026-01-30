import 'package:site_project_tracker/features/home/domain/repositories/llm_expense_repository.dart';
import 'package:site_project_tracker/features/home/domain/entities/llm_parsed_expense.dart';

class ParseExpenseWithAi {
  final LLMExpenseRepository repository;

  ParseExpenseWithAi(this.repository);

  Future<LLMExpenseDraft> call(String input) {
    return repository.parseExpense(input);
  }
}
