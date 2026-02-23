import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/presentation/dice_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/poem_slip_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tarot_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/tools_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P1-8 ToolsScreen 入口与子路由导航', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppAtTools(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/tools'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P1-8-W1: ToolsScreen 含至少三个可点击入口（骰子、诗签、占卜）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ToolsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ToolsScreen.keyToolDice), findsOneWidget);
      expect(find.byKey(ToolsScreen.keyToolPoemSlip), findsOneWidget);
      expect(find.byKey(ToolsScreen.keyToolTarot), findsOneWidget);
    });

    testWidgets('P1-8-W2: 点击骰子入口后跳转到 /tools/dice（或约定路径）', (
      WidgetTester tester,
    ) async {
      await pumpAppAtTools(tester);
      expect(find.byType(ToolsScreen), findsOneWidget);

      await tester.tap(find.byKey(ToolsScreen.keyToolDice));
      await tester.pumpAndSettle();

      expect(find.byType(DiceScreen), findsOneWidget);
    });
  });

  group('P1-10 工具聚合页入口为按钮形式排布', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('P1-10-W1: ToolsScreen 中三个工具入口以按钮形式排布', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ToolsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNWidgets(3));
      expect(find.byKey(ToolsScreen.keyToolDice), findsOneWidget);
      expect(find.byKey(ToolsScreen.keyToolPoemSlip), findsOneWidget);
      expect(find.byKey(ToolsScreen.keyToolTarot), findsOneWidget);
    });

    testWidgets('P1-10-W2: 按钮排布下点击骰子/诗签/占卜仍正确跳转至对应子路由', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/tools'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ToolsScreen.keyToolDice));
      await tester.pumpAndSettle();
      expect(find.byType(DiceScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ToolsScreen.keyToolPoemSlip));
      await tester.pumpAndSettle();
      expect(find.byType(PoemSlipScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ToolsScreen.keyToolTarot));
      await tester.pumpAndSettle();
      expect(find.byType(TarotScreen), findsOneWidget);
    });
  });
}
