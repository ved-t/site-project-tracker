import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_project_tracker/features/home/domain/usecases/parse_expense_with_llm.dart';
import 'package:site_project_tracker/core/utils/dio_error_handler.dart';
import 'ai_quick_input_state.dart';

class LLMInputController extends StateNotifier<LLMInputState> {
  final ParseExpenseWithAi parseExpense;

  LLMInputController(this.parseExpense) : super(const LLMInputState.initial());

  Future<void> submit(String input, String deviceId) async {
    state = const LLMInputState.loading();

    try {
      final draft = await parseExpense(input, deviceId);
      state = LLMInputState.success(draft);
    } catch (e) {
      final message = DioErrorHandler.getErrorMessage(e);
      state = LLMInputState.error(message);
    }
  }
}
