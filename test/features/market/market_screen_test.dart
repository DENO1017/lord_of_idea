import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/market/presentation/market_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P0-12 MarketScreen 及路由', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpApp(
      WidgetTester tester, {
      String initialLocation = '/market',
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

    testWidgets('P0-12-W1: 路由 /market 解析为 MarketScreen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: '/market');
      expect(find.byType(MarketScreen), findsOneWidget);
    });

    testWidgets('P0-12-W3: MarketScreen 能 build 且含可识别内容（市集或路由文案）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MarketScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('market_screen_title')), findsOneWidget);
      expect(find.text('市集'), findsOneWidget);
    });

    testWidgets('P0-12-W3 (en): MarketScreen 显示英文「Market」', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MarketScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Market'), findsOneWidget);
    });
  });
}
