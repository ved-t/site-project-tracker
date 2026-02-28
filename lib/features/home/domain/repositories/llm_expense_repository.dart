import 'package:site_project_tracker/features/home/domain/entities/llm_parsed_expense.dart';

abstract class LLMExpenseRepository {
  Future<LLMExpenseDraft> parseExpense(String input, String deviceId);
}
