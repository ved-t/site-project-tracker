import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:site_project_tracker/features/home/domain/entities/llm_parsed_expense.dart';

part 'ai_quick_input_state.freezed.dart';

@freezed
class LLMInputState with _$LLMInputState {
  const factory LLMInputState.initial() = _Initial;
  const factory LLMInputState.loading() = _Loading;
  const factory LLMInputState.success(LLMExpenseDraft draft) = _Success;
  const factory LLMInputState.error(String message) = _Error;
}
