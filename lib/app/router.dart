import 'package:go_router/go_router.dart';
import '../features/sites/site_shell_screen.dart';
import 'root_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
