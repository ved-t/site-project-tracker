import 'package:site_project_tracker/features/home/data/models/llm_expense_dto.dart';
import 'package:site_project_tracker/features/home/domain/entities/llm_parsed_expense.dart';
import 'package:site_project_tracker/features/home/data/datasources/llm_expense_parser.dart';
import 'package:site_project_tracker/features/home/domain/repositories/llm_expense_repository.dart';

class LLMExpenseRepositoryImpl implements LLMExpenseRepository {
  final LLMExpenseParser parser;

  LLMExpenseRepositoryImpl(this.parser);

  @override
  Future<LLMExpenseDraft> parseExpense(String input, String deviceId) async {
    final json = await parser.parseExpense(input, deviceId);
    final dto = LLMExpenseDto.fromJson(json);

    return LLMExpenseDraft(
      title: dto.title,
      amount: dto.amount,
      siteId: dto.siteId,
      categoryId: dto.categoryId,
      vendorId: dto.vendorId,
      date: dto.date,
      remarks: dto.remarks,
    );
  }
}
