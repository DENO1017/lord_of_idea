import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/domain/poem_slip_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/poem_slip_service.dart';
import 'package:lord_of_idea/features/divination/presentation/poem_slip_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock 诗签服务：固定返回一条签文，便于 P1-5-W2 断言 content。
class _MockPoemSlipService extends PoemSlipService {
  _MockPoemSlipService() : super();

  @override
  Future<PoemSlipResult> draw(String libraryId) async {
    return PoemSlipResult(
      createdAt: DateTime.now().toUtc(),
      libraryId: libraryId,
      slipId: 'slip_001',
      content: '测试签文内容',
    );
  }
}

void main() {
  group('P1-5 PoemSlipScreen 与路由', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppToPoemSlip(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/tools/poem-slip'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P1-5-W1: PoemSlipScreen 含抽签按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PoemSlipScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('poem_slip_draw_button')), findsOneWidget);
    });

    testWidgets('P1-5-W2: 点击抽签后展示签条内容（content）', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            poemSlipServiceProvider.overrideWithValue(_MockPoemSlipService()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PoemSlipScreen(),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('poem_slip_draw_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('测试签文内容'), findsOneWidget);
      expect(find.byKey(const Key('poem_slip_result_card')), findsOneWidget);
    });

    testWidgets('B-P1-1-003/P1-15: 抽签后签头为人性化文案，不直接显示签 id', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            poemSlipServiceProvider.overrideWithValue(_MockPoemSlipService()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PoemSlipScreen(),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('poem_slip_draw_button')));
      await tester.pumpAndSettle();

      final header = find.byKey(const Key('poem_slip_header'));
      expect(header, findsOneWidget);
      final headerText =
          (tester.widget<Text>(header)).data ??
          (tester.widget<Text>(header)).textSpan?.toPlainText() ??
          '';
      expect(headerText, isNot(equals('slip_001')));
      expect(headerText, contains('1'));
    });

    testWidgets('P1-5-W3: 路由 /tools/poem-slip 解析为 PoemSlipScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppToPoemSlip(tester);
      expect(find.byType(PoemSlipScreen), findsOneWidget);
    });
  });
}
