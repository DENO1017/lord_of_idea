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
import 'package:lord_of_idea/features/market/presentation/market_screen.dart';
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
          } else if (r is ShellRoute) {
            collectPaths(r.routes, prefix: prefix);
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
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ToolsScreen(),
          ),
        );
        expect(find.byKey(ToolsScreen.keyToolDice), findsOneWidget);
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

  group('P0-11 Main shell and bottom nav', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppWithEn(
      WidgetTester tester, {
      String initialLocation = '/home',
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await storage.setString('lord_of_idea.locale_language_code', 'en');
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

    testWidgets('P0-11-W1: 主壳内可见五个页签（首页、工具、手账、市集、我的）', (
      WidgetTester tester,
    ) async {
      await pumpAppWithEn(tester, initialLocation: '/home');
      final nav = find.byKey(const Key('main_shell_bottom_nav'));
      expect(nav, findsOneWidget);
      expect(
        find.descendant(of: nav, matching: find.text('Home')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Tools')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Journal')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Market')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Me')),
        findsOneWidget,
      );
    });

    testWidgets('P0-11-W2: 点击「市集」页签后当前路由为 /market，内容区为 MarketScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppWithEn(tester, initialLocation: '/home');
      await tester.tap(find.text('Market'));
      await tester.pumpAndSettle();
      expect(find.byType(MarketScreen), findsOneWidget);
      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig
              as GoRouter;
      expect(router.routerDelegate.currentConfiguration.uri.path, '/market');
    });

    testWidgets('P0-11-W3: 点击「我的」页签后当前路由为 /me，内容区为 SettingsScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppWithEn(tester, initialLocation: '/home');
      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig
              as GoRouter;
      expect(router.routerDelegate.currentConfiguration.uri.path, '/me');
    });

    testWidgets('P0-11-W4: 深链 go(/market) 后显示市集页且底部市集页签高亮', (
      WidgetTester tester,
    ) async {
      await pumpAppWithEn(tester, initialLocation: '/market');
      expect(find.byType(MarketScreen), findsOneWidget);
      expect(find.byKey(const Key('main_shell_bottom_nav')), findsOneWidget);
    });
  });

  group('P0-13 底部导航市集、我的文案（l10n navMarket、navMe）', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppWithZh(
      WidgetTester tester, {
      String initialLocation = '/home',
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await storage.setString('lord_of_idea.locale_language_code', 'zh');
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

    testWidgets('P0-13-W1: locale 为 zh 时底部「市集」「我的」为中文', (
      WidgetTester tester,
    ) async {
      await pumpAppWithZh(tester, initialLocation: '/home');
      final nav = find.byKey(const Key('main_shell_bottom_nav'));
      expect(nav, findsOneWidget);
      expect(
        find.descendant(of: nav, matching: find.text('市集')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('我的')),
        findsOneWidget,
      );
    });

    testWidgets('P0-13-W2: locale 为 en 时底部为 "Market"、"Me"', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await storage.setString('lord_of_idea.locale_language_code', 'en');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/home'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      final nav = find.byKey(const Key('main_shell_bottom_nav'));
      expect(nav, findsOneWidget);
      expect(
        find.descendant(of: nav, matching: find.text('Market')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nav, matching: find.text('Me')),
        findsOneWidget,
      );
    });
  });
}
