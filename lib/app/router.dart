import 'package:go_router/go_router.dart';
import '../features/auth/presentation/controllers/auth_provider.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/presentation/screens/register_page.dart';
import '../features/auth/presentation/screens/forgot_password_page.dart';
import '../features/sites/site_shell_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../core/services/local_storage_service.dart';
import 'root_screen.dart';

GoRouter createRouter(
  AuthProvider authProvider,
  LocalStorageService localStorage,
) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) async {
      final isLoggedIn = authProvider.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isResettingPassword = state.matchedLocation == '/forgot-password';
      final isOnboarding = state.matchedLocation == '/onboarding';

      final hasSeenOnboarding = await localStorage.getHasSeenOnboarding();

      if (!hasSeenOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      if (hasSeenOnboarding && isOnboarding) {
        return isLoggedIn ? '/' : '/login';
      }

      if (!isLoggedIn &&
          !isLoggingIn &&
          !isRegistering &&
          !isResettingPassword &&
          !isOnboarding)
        return '/login';
      if (isLoggedIn &&
          (isLoggingIn || isRegistering || isResettingPassword || isOnboarding))
        return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
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
