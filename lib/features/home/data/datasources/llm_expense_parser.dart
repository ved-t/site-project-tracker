import 'package:dio/dio.dart';

class LLMExpenseParser {
  final Dio dio;

  LLMExpenseParser(this.dio);

  Future<Map<String, dynamic>> parseExpense(String payload) async {
    final response = await dio.post(
      '/api/v1/ai/parse-expense',
      data: payload,
      options: Options(contentType: Headers.textPlainContentType),
    );

    print('LLM Expense Parser Response: ${response.data}');

    return response.data;
  }
}
