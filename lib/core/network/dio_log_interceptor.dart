import 'package:dio/dio.dart';
import 'package:site_project_tracker/core/utils/logger.dart';

class DioLogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '❌ [DIO] BACKGROUND ERROR: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
      name: 'DIO_BG',
    );

    // Continue with the error so it can be handled by the UI/Controller
    handler.next(err);
  }
}
