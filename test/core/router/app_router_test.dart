import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/presentation/tools_screen.dart';
import 'package:lord_of_idea/features/home/presentation/home_screen.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_detail_screen.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_list_screen.dart';
import 'package:lord_of_idea/features/settings/presentation/settings_screen.dart';
import 'package:lord_of_idea/features/shared_journal/presentation/shared_journal_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-3 Router', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('P0-3-U1: redirect 当 location 为 / 时返回 /home', () {
      expect(redirectByLocation('/', {}), '/home');
    });

    test('P0-3-U2: redirect 当 location 为 /journal 时不变', () {
      expect(redirectByLocation('/journal', {}), isNull);
    });

    test('P0-3-U3: 路由表包含 /home、/settings、/journal、/journal/:id', () {
      final router = createAppRouter();
      final paths = <String>[];
      void collectPaths(List<RouteBase> routes, {String prefix = ''}) {
        for (final r in routes) {
          if (r is GoRoute) {
            final p = r.path.startsWith('/')
                ? r.path
                : (prefix.isEmpty ? '/${r.path}' : '$prefix/${r.path}');
            paths.add(p);
            if (r.routes.isNotEmpty) {
              collectPaths(r.routes, prefix: p);
            }
          }
        }
      }

      collectPaths(router.configuration.routes);
      expect(paths, contains('/home'));
      expect(paths, contains('/settings'));
      expect(paths, contains('/journal'));
      expect(paths, contains('/journal/:id'));
    });

    Future<void> pumpAppAndSettle(
      WidgetTester tester, {
      String initialLocation = '/',
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: initialLocation),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P0-3-W1: 导航到 /home 后可见 HomeScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppAndSettle(tester, initialLocation: '/home');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('P0-3-W2: 导航到 /settings 后可见 SettingsScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppAndSettle(tester, initialLocation: '/settings');
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('P0-3-W3: 初始 location 为 / 时 redirect 后最终显示 HomeScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppAndSettle(tester, initialLocation: '/');
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    group('P0-3-W4: 各占位 Screen 能 build 且包含可识别内容', () {
      testWidgets('HomeScreen', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('ToolsScreen', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: ToolsScreen()));
        expect(find.byKey(const Key('tools_screen_title')), findsOneWidget);
      });

      testWidgets('JournalListScreen', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: JournalListScreen()));
        expect(
          find.byKey(const Key('journal_list_screen_title')),
          findsOneWidget,
        );
      });

      testWidgets('JournalDetailScreen', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: JournalDetailScreen(journalId: 'test-id')),
        );
        expect(
          find.byKey(const Key('journal_detail_screen_title')),
          findsOneWidget,
        );
        expect(find.textContaining('test-id'), findsOneWidget);
      });

      testWidgets('SharedJournalScreen', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SharedJournalScreen(journalId: 'shared-1')),
        );
        expect(
          find.byKey(const Key('shared_journal_screen_title')),
          findsOneWidget,
        );
        expect(find.textContaining('shared-1'), findsOneWidget);
      });

      testWidgets('SettingsScreen', (WidgetTester tester) async {
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorageService(prefs);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [localStorageProvider.overrideWithValue(storage)],
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SettingsScreen(),
            ),
          ),
        );
        expect(find.byKey(const Key('settings_screen_title')), findsOneWidget);
      });
    });
  });
}
