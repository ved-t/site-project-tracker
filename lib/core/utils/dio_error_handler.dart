import 'package:dio/dio.dart';

class DioErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.sendTimeout:
          return 'Unable to send data. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Server took too long to respond.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              return 'Server error ($statusCode). Please try again later.';
            } else if (statusCode == 404) {
              return 'Resource not found.';
            } else if (statusCode == 401 || statusCode == 403) {
              return 'Access denied.';
            }
          }
          return 'Something went wrong. Please try again.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        case DioExceptionType.unknown:
          return 'An unexpected error occurred.';
        default:
          return 'Network error. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
