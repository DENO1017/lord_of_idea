import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/features/divination/domain/tool_history_provider.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_detail_screen.dart';
import 'package:lord_of_idea/features/divination/presentation/dice_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart'
    show DiceResult, SingleRoll;
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P2-6 手帐编辑态工具栏调用工具并插入', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpDetailScreenEdit(
      WidgetTester tester, {
      required String journalId,
      required String pageId,
      Journal? journal,
      List<JournalPage>? pages,
      List<JournalBlock>? blocks,
    }) async {
      final j =
          journal ??
          Journal(
            id: journalId,
            title: 'Test',
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 2),
          );
      final pList =
          pages ??
          [
            JournalPage(
              id: pageId,
              journalId: journalId,
              orderIndex: 0,
              createdAt: DateTime(2025, 1, 1),
            ),
          ];
      final blocksByPageId = <String, List<JournalBlock>>{pageId: blocks ?? []};
      final mockRepo = _MutableMockJournalRepository(
        journal: j,
        pages: pList,
        blocksByPageId: blocksByPageId,
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: JournalDetailScreen(journalId: journalId, pageId: pageId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal_detail_edit_toggle')));
      await tester.pumpAndSettle();
    }

    testWidgets('P2-6-W1: 编辑态下工具栏含骰子/诗签/占卜入口', (WidgetTester tester) async {
      const journalId = 'j1';
      const pageId = 'p1';
      await pumpDetailScreenEdit(tester, journalId: journalId, pageId: pageId);
      expect(
        find.byKey(const Key('journal_detail_edit_toolbar')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal_toolbar_dice')), findsOneWidget);
      expect(
        find.byKey(const Key('journal_toolbar_poem_slip')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal_toolbar_tarot')), findsOneWidget);
    });

    testWidgets('P2-6-W2: 从工具栏选择历史结果插入后当前页块数+1且为对应类型', (
      WidgetTester tester,
    ) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final diceForHistory = DiceResult(
        createdAt: DateTime(2025, 1, 1).toUtc(),
        expression: '2d6',
        rolls: const [
          SingleRoll(faces: 6, value: 3),
          SingleRoll(faces: 6, value: 4),
        ],
        total: 7,
      );
      final historyWithDice = ToolHistoryState(dice: [diceForHistory]);
      final blocksByPageId = <String, List<JournalBlock>>{pageId: []};
      final mockRepo = _MutableMockJournalRepository(
        journal: Journal(
          id: journalId,
          title: 'Test',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
        ),
        pages: [
          JournalPage(
            id: pageId,
            journalId: journalId,
            orderIndex: 0,
            createdAt: DateTime(2025, 1, 1),
          ),
        ],
        blocksByPageId: blocksByPageId,
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            journalRepositoryProvider.overrideWithValue(mockRepo),
            toolHistoryProvider.overrideWith(
              () => _FixedToolHistoryNotifier(historyWithDice),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: JournalDetailScreen(journalId: journalId, pageId: pageId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal_detail_edit_toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('journal_toolbar_dice')), findsOneWidget);
      await tester.tap(find.byKey(const Key('journal_toolbar_dice')));
      await tester.pumpAndSettle();
      final listTile = find.text('2d6=7');
      expect(listTile, findsOneWidget);
      await tester.tap(listTile);
      await tester.pumpAndSettle();
      final blocks = await _getBlocksFromRepo(tester, pageId);
      expect(blocks.length, 1);
      expect(blocks.first.type, 'dice');
      final payload = jsonDecode(blocks.first.payload) as Map<String, dynamic>;
      expect(payload['expression'], '2d6');
      expect(payload['total'], 7);
    });

    testWidgets('P2-6-W3: 从工具栏现场调用工具（掷骰）得到结果插入后当前页块数+1', (
      WidgetTester tester,
    ) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final blocksByPageId = <String, List<JournalBlock>>{pageId: []};
      final mockRepo = _MutableMockJournalRepository(
        journal: Journal(
          id: journalId,
          title: 'Test',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
        ),
        pages: [
          JournalPage(
            id: pageId,
            journalId: journalId,
            orderIndex: 0,
            createdAt: DateTime(2025, 1, 1),
          ),
        ],
        blocksByPageId: blocksByPageId,
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: JournalDetailScreen(journalId: journalId, pageId: pageId),
          ),
        ),
      );
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
      final okButton = find.byWidgetPredicate(
        (w) =>
            w is FilledButton && w.key == const Key('journal_tool_dice_insert'),
      );
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
      } else {
        await tester.tap(find.text('OK'));
      }
      await tester.pumpAndSettle();
      final blocks = await mockRepo.getBlocks(pageId);
      expect(blocks.length, 1);
      expect(blocks.first.type, 'dice');
    });

    testWidgets('P2-6-W4: 独立工具页 /tools/dice 无「插入手帐」按钮', (
      WidgetTester tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localStorageProvider.overrideWithValue(storage)],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DiceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DiceScreen), findsOneWidget);
      expect(find.text('插入手帐'), findsNothing);
      expect(find.text('Insert to journal'), findsNothing);
    });
  });
}

Future<List<JournalBlock>> _getBlocksFromRepo(
  WidgetTester tester,
  String pageId,
) async {
  final finder = find.byKey(const Key('journal_detail_edit_toolbar'));
  expect(finder, findsOneWidget);
  final container = ProviderScope.containerOf(tester.element(finder));
  final repo = container.read(journalRepositoryProvider);
  return repo.getBlocks(pageId);
}

class _FixedToolHistoryNotifier extends ToolHistoryNotifier {
  _FixedToolHistoryNotifier(this._state);

  final ToolHistoryState _state;

  @override
  ToolHistoryState build() => _state;
}

class _MutableMockJournalRepository implements JournalRepository {
  _MutableMockJournalRepository({
    required this.journal,
    required this.pages,
    required this.blocksByPageId,
  });

  final Journal? journal;
  final List<JournalPage> pages;
  final Map<String, List<JournalBlock>> blocksByPageId;

  @override
  Future<Journal?> getJournalById(String id) async => journal;

  @override
  Future<List<JournalPage>> getPages(String journalId) async => pages;

  @override
  Future<List<JournalBlock>> getBlocks(String pageId) async {
    final list = blocksByPageId[pageId] ?? [];
    return List.from(list);
  }

  @override
  Future<List<Journal>> getAllJournals() async => [
    ...?(journal != null ? [journal!] : null),
  ];

  @override
  Future<Journal> createJournal({String? title}) async =>
      throw UnimplementedError();

  @override
  Future<void> updateJournal(Journal j) async {}

  @override
  Future<void> deleteJournal(String id) async {}

  @override
  Future<JournalPage> addPage(String journalId) async =>
      throw UnimplementedError();

  @override
  Future<JournalBlock> addBlock(String pageId, JournalBlock block) async {
    final list = blocksByPageId.putIfAbsent(pageId, () => []);
    final nextIndex = list.length;
    final toInsert = JournalBlock(
      id: block.id,
      pageId: pageId,
      type: block.type,
      orderIndex: nextIndex,
      payload: block.payload,
      createdAt: block.createdAt,
    );
    list.add(toInsert);
    return toInsert;
  }

  @override
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {}
}
