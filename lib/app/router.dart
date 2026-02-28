import 'package:go_router/go_router.dart';
import '../features/auth/presentation/controllers/auth_provider.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/presentation/screens/register_page.dart';
import '../features/auth/presentation/screens/forgot_password_page.dart';
import '../features/sites/site_shell_screen.dart';
import 'root_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      
      final isLoggedIn = authProvider.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isResettingPassword = state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isLoggingIn && !isRegistering && !isResettingPassword)
        return '/login';
      if (isLoggedIn && (isLoggingIn || isRegistering || isResettingPassword))
        return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const RootScreen(),
        routes: [
          GoRoute(
            path: 'expenses/:siteId',
            builder: (context, state) {
              final siteId = state.pathParameters['siteId']!;
              return SiteShellScreen(siteId: siteId);
            },
          ),
        ],
      ),
    ],
  );
}
