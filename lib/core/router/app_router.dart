import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/core/router/main_shell.dart';
import 'package:lord_of_idea/features/divination/presentation/dice_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/poem_slip_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tarot_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tools_screen.dart';
import 'package:lord_of_idea/features/home/presentation/home_screen.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_detail_screen.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_list_screen.dart';
import 'package:lord_of_idea/features/market/presentation/market_screen.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:lord_of_idea/features/shared_journal/presentation/shared_journal_screen.dart';

/// Builds the app GoRouter. [initialLocation] is for tests (defaults to '/').
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: _redirect,
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

String? _redirect(BuildContext context, GoRouterState state) {
  return redirectByLocation(state.matchedLocation, state.pathParameters);
}
