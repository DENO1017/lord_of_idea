import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/core/router/main_shell.dart';
import 'package:lord_of_idea/features/divination/presentation/dice_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/poem_slip_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tarot_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tools_screen.dart';
import 'package:lord_of_idea/features/home/presentation/home_screen.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_detail_screen.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_list_screen.dart';
import 'package:lord_of_idea/features/market/presentation/market_screen.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:lord_of_idea/features/shared_journal/presentation/shared_journal_screen.dart';

/// Builds the app GoRouter. [initialLocation] is for tests (defaults to '/').
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: _redirectAsync,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShell(state: state, child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen(),
          ),
          GoRoute(
            path: '/tools',
            builder: (BuildContext context, GoRouterState state) =>
                const ToolsScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'dice',
                builder: (BuildContext context, GoRouterState state) =>
                    const DiceScreen(),
              ),
              GoRoute(
                path: 'poem-slip',
                builder: (BuildContext context, GoRouterState state) =>
                    const PoemSlipScreen(),
              ),
              GoRoute(
                path: 'tarot',
                builder: (BuildContext context, GoRouterState state) =>
                    const TarotScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/journal',
            builder: (BuildContext context, GoRouterState state) =>
                const JournalListScreen(),
          ),
          GoRoute(
            path: '/market',
            builder: (BuildContext context, GoRouterState state) =>
                const MarketScreen(),
          ),
          GoRoute(
            path: '/me',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/journal/:id',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return JournalDetailScreen(journalId: id);
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'page/:pageId',
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id'] ?? '';
              final pageId = state.pathParameters['pageId'];
              return JournalDetailScreen(journalId: id, pageId: pageId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/shared-journal/:id',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return SharedJournalScreen(journalId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) => createAppRouter());

/// Redirect logic for unit tests: / → /home; invalid journal/:id → /journal.
String? redirectByLocation(
  String matchedLocation,
  Map<String, String> pathParameters,
) {
  if (matchedLocation == '/') return '/home';
  if (matchedLocation.startsWith('/journal/')) {
    final id = pathParameters['id'];
    if (id == null || id.isEmpty) return '/journal';
  }
  return null;
}

/// 异步 redirect：先执行同步规则，再校验 journal id 是否存在，不存在则重定向到 /journal。
Future<String?> _redirectAsync(
  BuildContext context,
  GoRouterState state,
) async {
  final sync = redirectByLocation(state.matchedLocation, state.pathParameters);
  if (sync != null) return sync;
  final loc = state.matchedLocation;
  final id = state.pathParameters['id'];
  if (loc.startsWith('/journal/') &&
      id != null &&
      id.isNotEmpty &&
      (loc == '/journal/$id' || loc.startsWith('/journal/$id/'))) {
    try {
      final container = ProviderScope.containerOf(context);
      final repo = container.read(journalRepositoryProvider);
      final journal = await repo.getJournalById(id);
      if (journal == null) return '/journal';
    } catch (_) {
      return '/journal';
    }
  }
  return null;
}
