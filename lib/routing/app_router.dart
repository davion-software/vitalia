import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalia/features/app_shell/presentation/app_shell.dart';
import 'package:vitalia/features/history/presentation/history_screen.dart';
import 'package:vitalia/features/medications/presentation/medication_editor_screen.dart';
import 'package:vitalia/features/medications/presentation/medications_screen.dart';
import 'package:vitalia/features/settings/presentation/settings_screen.dart';
import 'package:vitalia/features/today/presentation/today_screen.dart';
import 'package:vitalia/routing/error_screen.dart';
import 'package:vitalia/routing/routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.today,
    errorBuilder: (context, state) =>
        ErrorScreen(message: state.error?.toString() ?? state.uri.toString()),
    routes: [
      GoRoute(
        path: Routes.newMedication,
        builder: (context, state) => const MedicationEditorScreen(),
      ),
      GoRoute(
        path: '/medications/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) {
            return const ErrorScreen(message: 'Missing medication id.');
          }
          return MedicationEditorScreen(medicationId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.medications,
                builder: (context, state) => const MedicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
