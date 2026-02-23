import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/divination/domain/dice_roller_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';
import 'package:lord_of_idea/features/divination/presentation/dice_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P1-3 DiceScreen 与路由', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAppToDice(WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/tools/dice'),
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P1-3-W1: DiceScreen 含输入框与掷骰按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('dice_expression_input')),
      );
      expect(find.byKey(const Key('dice_expression_input')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      expect(find.byKey(const Key('dice_roll_button')), findsOneWidget);
    });

    testWidgets('P1-3-W2: 输入合法表达式并点击掷骰后展示结果区域（含 total 或 rolls）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );

      await tester.ensureVisible(
        find.byKey(const Key('dice_expression_input')),
      );
      await tester.enterText(
        find.byKey(const Key('dice_expression_input')),
        '2d6',
      );
      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      await tester.tap(find.byKey(const Key('dice_roll_button')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('dice_result_card')));
      expect(find.byKey(const Key('dice_result_card')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w).data != null &&
              ((w).data!.contains('总计') || (w).data!.contains('Total')),
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('P1-3-W3: 路由 /tools/dice 解析为 DiceScreen', (
      WidgetTester tester,
    ) async {
      await pumpAppToDice(tester);
      expect(find.byType(DiceScreen), findsOneWidget);
    });

    testWidgets('P1-9-W1: 骰子结果页有保存并复制按钮，点击后剪贴板为约定格式（表达式=总和，无空格）', (
      WidgetTester tester,
    ) async {
      String? capturedClipboardText;
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              final args = methodCall.arguments as Map<Object?, Object?>;
              capturedClipboardText = args['text'] as String?;
            }
            return null;
          });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diceRollerProvider.overrideWithValue(DiceRoller(Random(42))),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );
      await tester.ensureVisible(
        find.byKey(const Key('dice_expression_input')),
      );
      await tester.enterText(
        find.byKey(const Key('dice_expression_input')),
        '2d6',
      );
      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      await tester.tap(find.byKey(const Key('dice_roll_button')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('dice_save_copy_button')),
      );
      expect(find.byKey(const Key('dice_save_copy_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dice_save_copy_button')));
      await tester.pumpAndSettle();

      expect(capturedClipboardText, isNotNull);
      // 规格 §5.4：无空格，表达式+等号+总和，如 3d6+3=7
      expect(capturedClipboardText!, matches(RegExp(r'^2d6=\d+$')));
    });

    testWidgets('P1-11 / B-P1-1-001: d100（2d10）掷骰后展示十位/个位且总分为 1～100', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diceRollerProvider.overrideWithValue(DiceRoller(Random(456))),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );
      await tester.ensureVisible(
        find.byKey(const Key('dice_expression_input')),
      );
      await tester.enterText(
        find.byKey(const Key('dice_expression_input')),
        '2d10',
      );
      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      await tester.tap(find.byKey(const Key('dice_roll_button')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('dice_result_card')));
      expect(find.byKey(const Key('dice_result_card')), findsOneWidget);
      final card = find.byKey(const Key('dice_result_card'));
      expect(
        find.descendant(of: card, matching: find.textContaining('十位')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.textContaining('个位')),
        findsOneWidget,
      );
      final totalText = find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (w) => w is Text && (w).data != null && (w).data!.contains('：'),
        ),
      );
      expect(totalText, findsWidgets);
      final fullCardText = tester
          .widgetList<Text>(
            find.descendant(of: card, matching: find.byType(Text)),
          )
          .map((t) => t.data ?? '')
          .join(' ');
      final totalMatch = RegExp(
        r'总计[：:]\s*(\d+)|Total[：:]\s*(\d+)',
      ).firstMatch(fullCardText);
      expect(totalMatch, isNotNull);
      final totalStr = totalMatch!.group(1) ?? totalMatch.group(2)!;
      final total = int.parse(totalStr);
      expect(total, greaterThanOrEqualTo(1));
      expect(total, lessThanOrEqualTo(100));
    });

    testWidgets('P1-12 / B-P1-1-002: 未点舍弃/重 Roll 时再次掷骰，上次结果进入历史且当前仅展示本轮结果', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diceRollerProvider.overrideWithValue(DiceRoller(Random(100))),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );
      await tester.ensureVisible(
        find.byKey(const Key('dice_expression_input')),
      );
      await tester.enterText(
        find.byKey(const Key('dice_expression_input')),
        'd6',
      );
      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      await tester.tap(find.byKey(const Key('dice_roll_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dice_result_card')), findsOneWidget);
      final cardBefore = find.byKey(const Key('dice_result_card'));
      final totalTextBefore = tester
          .widgetList<Text>(
            find.descendant(of: cardBefore, matching: find.byType(Text)),
          )
          .map((t) => t.data ?? '')
          .join(' ');
      final totalMatchBefore = RegExp(
        r'总计[：:]\s*(\d+)|Total[：:]\s*(\d+)',
      ).firstMatch(totalTextBefore);
      expect(totalMatchBefore, isNotNull);
      final firstTotal =
          totalMatchBefore!.group(1) ?? totalMatchBefore.group(2)!;

      await tester.ensureVisible(find.byKey(const Key('dice_roll_button')));
      await tester.tap(find.byKey(const Key('dice_roll_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dice_result_card')), findsOneWidget);
      final cardAfter = find.byKey(const Key('dice_result_card'));
      final totalTextAfter = tester
          .widgetList<Text>(
            find.descendant(of: cardAfter, matching: find.byType(Text)),
          )
          .map((t) => t.data ?? '')
          .join(' ');
      final totalMatchAfter = RegExp(
        r'总计[：:]\s*(\d+)|Total[：:]\s*(\d+)',
      ).firstMatch(totalTextAfter);
      expect(totalMatchAfter, isNotNull);
      final secondTotal =
          totalMatchAfter!.group(1) ?? totalMatchAfter.group(2)!;

      expect(find.textContaining('d6=$firstTotal'), findsOneWidget);
      expect(find.textContaining(secondTotal), findsAtLeastNWidgets(1));
    });
  });
}
