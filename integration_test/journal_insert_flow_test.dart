import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('P2-6-I1 手帐编辑态工具栏插入骰子', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('进手帐编辑 → 工具栏调用骰子并插入 → 当前页可见骰子块', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: Consumer(
            builder: (_, WidgetRef ref, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(appRouterProvider).go('/journal');
              });
              return const MyApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final createBtn = find.byKey(const Key('journal_list_create_button'));
      if (createBtn.evaluate().isNotEmpty) {
        await tester.tap(createBtn);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'P2-6 Test');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      final journalCard = find.byType(Card).first;
      if (journalCard.evaluate().isNotEmpty) {
        await tester.tap(journalCard);
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('journal_detail_edit_toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('journal_toolbar_dice')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('journal_tool_use_live_dice')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('journal_tool_dice_expression')),
        'd6',
      );
      await tester.tap(find.byKey(const Key('journal_tool_dice_roll')));
      await tester.pumpAndSettle();

      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
      }
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal_block_dice')), findsOneWidget);
    });
  });
}
