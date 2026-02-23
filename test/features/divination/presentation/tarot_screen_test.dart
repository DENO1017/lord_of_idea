import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/domain/divination_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/divination_service.dart';
import 'package:lord_of_idea/features/divination/presentation/tarot_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock 占卜服务：loadDeck 立即返回固定牌组，drawOne 返回固定结果，便于 P1-7-W2 断言牌名与释义。
class _MockDivinationService extends DivinationService {
  _MockDivinationService() : super();

  static final List<TarotCard> _deck = [
    const TarotCard(
      cardId: 'rws_00',
      cardName: '愚者',
      uprightMeaning: '测试正位释义',
      reversedMeaning: '测试逆位释义',
    ),
  ];

  @override
  Future<List<TarotCard>> loadDeck(String assetPath) async {
    return _deck;
  }

  @override
  DivinationResult drawOne(
    List<TarotCard> deck,
    String deckId, {
    Random? random,
  }) {
    return DivinationResult(
      createdAt: DateTime.now().toUtc(),
      deckId: deckId,
      cardId: 'rws_00',
      cardName: '愚者',
      reversed: false,
      meaning: '测试正位释义',
      imagePathOrUrl: null,
    );
  }
}

void main() {
  group('P1-7 TarotScreen 与路由', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppToTarot(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/tools/tarot'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P1-7-W1: 占卜页含抽牌按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            divinationServiceProvider.overrideWithValue(
              _MockDivinationService(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TarotScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot_draw_button')), findsOneWidget);
    });

    testWidgets('P1-7-W2: 点击抽牌后展示牌名与释义', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            divinationServiceProvider.overrideWithValue(
              _MockDivinationService(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TarotScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tarot_draw_button')));
      await tester.pumpAndSettle();

      expect(find.text('愚者'), findsOneWidget);
      expect(find.textContaining('测试正位释义'), findsOneWidget);
      expect(find.byKey(const Key('tarot_result_card')), findsOneWidget);
    });

    testWidgets('P1-7-W3: 路由解析为占卜 Screen', (WidgetTester tester) async {
      await pumpAppToTarot(tester);
      expect(find.byType(TarotScreen), findsOneWidget);
    });
  });
}
