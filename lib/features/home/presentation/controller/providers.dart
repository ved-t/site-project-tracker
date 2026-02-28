import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/home/data/datasources/llm_expense_parser.dart';
import 'package:site_project_tracker/features/home/data/repositories/llm_expense_repository_impl.dart';
import 'package:site_project_tracker/features/home/domain/repositories/llm_expense_repository.dart';
import 'package:site_project_tracker/features/home/domain/usecases/parse_expense_with_llm.dart';
import 'package:site_project_tracker/features/home/presentation/controller/ai_quick_input.dart';
import 'package:site_project_tracker/features/home/presentation/controller/ai_quick_input_state.dart';

import 'package:site_project_tracker/core/services/sync_providers.dart';

final llmExpenseParserProvider = Provider<LLMExpenseParser>((ref) {
  final dio = ref.watch(dioProvider);
  return LLMExpenseParser(dio);
});

final llmExpenseRepositoryProvider = Provider<LLMExpenseRepository>((ref) {
  final parser = ref.watch(llmExpenseParserProvider);
  return LLMExpenseRepositoryImpl(parser);
});

final parseExpenseWithAiProvider = Provider<ParseExpenseWithAi>((ref) {
  final repository = ref.watch(llmExpenseRepositoryProvider);
  return ParseExpenseWithAi(repository);
});

final llmInputControllerProvider =
    StateNotifierProvider<LLMInputController, LLMInputState>((ref) {
      final parseExpense = ref.watch(parseExpenseWithAiProvider);
      return LLMInputController(parseExpense);
    });
