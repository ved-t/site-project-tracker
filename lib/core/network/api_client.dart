import 'package:dio/dio.dart';
import '../../features/auth/presentation/controllers/auth_provider.dart';

class ApiClient {
  final Dio dio;
  final AuthProvider authProvider;

  ApiClient(this.authProvider)
      : dio = Dio(BaseOptions(baseUrl: "https://your-backend.com")) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authProvider.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
