import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_detail_screen.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart'
    show DiceResult, SingleRoll;
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P2-4 JournalDetailScreen', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpDetailScreen(
      WidgetTester tester, {
      required String journalId,
      String? pageId,
      Journal? journal,
      List<JournalPage>? pages,
      List<JournalBlock>? blocks,
    }) async {
      Journal? resolvedJournal = journal;
      List<JournalPage> resolvedPages = pages ?? [];
      final pageIdToBlocks = <String, List<JournalBlock>>{};
      if (blocks != null && pages != null && pages.isNotEmpty) {
        pageIdToBlocks[pages.first.id] = blocks;
      }
      final mockRepo = _MockJournalRepository(
        journal: resolvedJournal,
        pages: resolvedPages,
        blocksByPageId: pageIdToBlocks,
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/journal'),
            ),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            home: JournalDetailScreen(journalId: journalId, pageId: pageId),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P2-4-W1: 展示当前页的块列表（text + dice）', (WidgetTester tester) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final journal = Journal(
        id: journalId,
        title: 'Test Journal',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final pages = [
        JournalPage(
          id: pageId,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final textPayload = '{"content":"Hello block"}';
      final dicePayload = jsonEncode(
        DiceResult(
          createdAt: DateTime(2025, 1, 1).toUtc(),
          expression: '2d6',
          rolls: [
            const SingleRoll(faces: 6, value: 3),
            const SingleRoll(faces: 6, value: 4),
          ],
          total: 7,
        ).toJson(),
      );
      final blocks = [
        JournalBlock(
          id: 'b1',
          pageId: pageId,
          type: 'text',
          orderIndex: 0,
          payload: textPayload,
          createdAt: DateTime(2025, 1, 1),
        ),
        JournalBlock(
          id: 'b2',
          pageId: pageId,
          type: 'dice',
          orderIndex: 1,
          payload: dicePayload,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      await pumpDetailScreen(
        tester,
        journalId: journalId,
        journal: journal,
        pages: pages,
        blocks: blocks,
      );
      expect(find.byKey(const Key('journal_block_text')), findsOneWidget);
      expect(find.text('Hello block'), findsOneWidget);
      expect(find.byKey(const Key('journal_block_dice')), findsOneWidget);
      expect(find.text('2d6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('P2-4-W2: 页签 N/Sum，切换页后展示对应块', (WidgetTester tester) async {
      const journalId = 'j2';
      const page1Id = 'p1';
      const page2Id = 'p2';
      final journal = Journal(
        id: journalId,
        title: 'Two Pages',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final pages = [
        JournalPage(
          id: page1Id,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
        JournalPage(
          id: page2Id,
          journalId: journalId,
          orderIndex: 1,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final mockRepo = _MockJournalRepository(
        journal: journal,
        pages: pages,
        blocksByPageId: {
          page1Id: [
            JournalBlock(
              id: 'b1',
              pageId: page1Id,
              type: 'text',
              orderIndex: 0,
              payload: '{"content":"Page 1"}',
              createdAt: DateTime(2025, 1, 1),
            ),
          ],
          page2Id: [
            JournalBlock(
              id: 'b2',
              pageId: page2Id,
              type: 'text',
              orderIndex: 0,
              payload: '{"content":"Page 2"}',
              createdAt: DateTime(2025, 1, 1),
            ),
          ],
        },
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(
                initialLocation: '/journal/$journalId/page/$page1Id',
              ),
            ),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);
      await tester.tap(find.text('2/2'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
    });

    testWidgets('P2-4-W3: 占卜块仅牌图；空页无占位文案', (WidgetTester tester) async {
      const journalId = 'j3';
      const pageWithDivId = 'p1';
      const pageEmptyId = 'p2';
      final journal = Journal(
        id: journalId,
        title: 'Divination',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final divResult = DivinationResult(
        createdAt: DateTime(2025, 1, 1).toUtc(),
        deckId: 'rws',
        cardId: '0',
        cardName: 'The Fool',
        reversed: true,
        meaning: 'Meaning text',
        imagePathOrUrl: null,
      );
      final pages = [
        JournalPage(
          id: pageWithDivId,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
        JournalPage(
          id: pageEmptyId,
          journalId: journalId,
          orderIndex: 1,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final mockRepo = _MockJournalRepository(
        journal: journal,
        pages: pages,
        blocksByPageId: {
          pageWithDivId: [
            JournalBlock(
              id: 'b1',
              pageId: pageWithDivId,
              type: 'divination',
              orderIndex: 0,
              payload: jsonEncode(divResult.toJson()),
              createdAt: DateTime(2025, 1, 1),
            ),
          ],
          pageEmptyId: [],
        },
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(
                initialLocation: '/journal/$journalId/page/$pageWithDivId',
              ),
            ),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('journal_block_divination_image')),
        findsOneWidget,
      );
      expect(find.text('The Fool'), findsNothing);
      expect(find.text('Meaning text'), findsNothing);
      expect(find.byKey(const Key('journalPageEmpty')), findsNothing);
      await tester.tap(find.text('2/2'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('journalPageEmpty')), findsNothing);
    });

    testWidgets('P2-4-W4: 路由 /journal/:id 解析为 JournalDetailScreen 且 id 传入', (
      WidgetTester tester,
    ) async {
      const id = 'abc';
      final journal = Journal(
        id: id,
        title: 'Journal ABC',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final mockRepo = _MockJournalRepository(
        journal: journal,
        pages: [
          JournalPage(
            id: 'p1',
            journalId: id,
            orderIndex: 0,
            createdAt: DateTime(2025, 1, 1),
          ),
        ],
        blocksByPageId: {'p1': []},
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/journal/$id'),
            ),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(JournalDetailScreen), findsOneWidget);
      expect(find.text('Journal ABC'), findsOneWidget);
    });

    testWidgets('P2-4-W5: 无效 journal id 时重定向到 /journal', (
      WidgetTester tester,
    ) async {
      final mockRepo = _MockJournalRepository(
        journal: null,
        pages: [],
        blocksByPageId: {},
      );
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
            appRouterProvider.overrideWithValue(
              createAppRouter(initialLocation: '/journal/invalid-id'),
            ),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig
              as GoRouter;
      expect(router.routerDelegate.currentConfiguration.uri.path, '/journal');
    });
  });

  group('P2-4-U1 块 payload 解析', () {
    test('type=dice 时 DiceResult.fromJson(payload) 不抛', () {
      final payload = jsonEncode({
        'type': 'dice',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'expression': '1d20',
        'rolls': [
          {'faces': 20, 'value': 15},
        ],
        'total': 15,
      });
      final map = jsonDecode(payload) as Map<String, dynamic>;
      expect(() => DiceResult.fromJson(map), returnsNormally);
      final result = DiceResult.fromJson(map);
      expect(result.expression, '1d20');
      expect(result.total, 15);
    });
  });

  group('P2-5 块编辑', () {
    testWidgets('P2-5-W1: 详情页有「添加文本块」或「添加块」入口', (WidgetTester tester) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final journal = Journal(
        id: journalId,
        title: 'Test',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final pages = [
        JournalPage(
          id: pageId,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final mockRepo = _MockJournalRepository(
        journal: journal,
        pages: pages,
        blocksByPageId: {pageId: []},
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
      expect(find.byKey(const Key('journal_detail_add_block')), findsOneWidget);
    });

    testWidgets('P2-5-W2: 添加文本块后列表中可见新块内容', (WidgetTester tester) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final journal = Journal(
        id: journalId,
        title: 'Test',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final pages = [
        JournalPage(
          id: pageId,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final blocksByPageId = <String, List<JournalBlock>>{pageId: []};
      final mockRepo = _MutableMockJournalRepository(
        journal: journal,
        pages: pages,
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
      await tester.tap(find.byKey(const Key('journal_detail_add_block')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('journal_add_block_text_field')),
        '测试',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('测试'), findsOneWidget);
    });

    testWidgets('P2-5-W3: 块支持拖拽或上移/下移后顺序改变', (WidgetTester tester) async {
      const journalId = 'j1';
      const pageId = 'p1';
      final journal = Journal(
        id: journalId,
        title: 'Test',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final pages = [
        JournalPage(
          id: pageId,
          journalId: journalId,
          orderIndex: 0,
          createdAt: DateTime(2025, 1, 1),
        ),
      ];
      final blocksByPageId = <String, List<JournalBlock>>{
        pageId: [
          JournalBlock(
            id: 'b1',
            pageId: pageId,
            type: 'text',
            orderIndex: 0,
            payload: '{"content":"First"}',
            createdAt: DateTime(2025, 1, 1),
          ),
          JournalBlock(
            id: 'b2',
            pageId: pageId,
            type: 'text',
            orderIndex: 1,
            payload: '{"content":"Second"}',
            createdAt: DateTime(2025, 1, 1),
          ),
        ],
      };
      final mockRepo = _MutableMockJournalRepository(
        journal: journal,
        pages: pages,
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
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      await tester.tap(find.byKey(const Key('journal_detail_edit_toggle')));
      await tester.pumpAndSettle();
      final listFinder = find.byKey(const Key('journal_detail_blocks_list'));
      expect(listFinder, findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      final secondBlockDragHandle = find
          .byType(ReorderableDragStartListener)
          .at(1);
      await tester.drag(secondBlockDragHandle, const Offset(0, -80));
      await tester.pumpAndSettle();
      final ordered = mockRepo.getBlocksOrder(pageId);
      expect(ordered.length, 2);
      expect(ordered[0], 'b2');
      expect(ordered[1], 'b1');
    });
  });
}

class _MockJournalRepository implements JournalRepository {
  _MockJournalRepository({
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
  Future<List<JournalBlock>> getBlocks(String pageId) async =>
      blocksByPageId[pageId] ?? [];

  @override
  Future<List<Journal>> getAllJournals() async => [];

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
  Future<JournalBlock> addBlock(String pageId, JournalBlock block) async =>
      throw UnimplementedError();

  @override
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {}
}

/// 可变的 Mock：addBlock 追加块，reorderBlocks 重排；用于 P2-5 Widget 测试。
class _MutableMockJournalRepository implements JournalRepository {
  _MutableMockJournalRepository({
    required this.journal,
    required this.pages,
    required this.blocksByPageId,
  });

  final Journal? journal;
  final List<JournalPage> pages;
  final Map<String, List<JournalBlock>> blocksByPageId;

  List<String> getBlocksOrder(String pageId) {
    final list = blocksByPageId[pageId] ?? [];
    return list.map((b) => b.id).toList();
  }

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
  Future<List<Journal>> getAllJournals() async => [];

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
  ) async {
    final list = blocksByPageId[pageId];
    if (list == null || list.isEmpty) return;
    final byId = {for (final b in list) b.id: b};
    final reordered = <JournalBlock>[];
    for (var i = 0; i < blockIdsInOrder.length; i++) {
      final b = byId[blockIdsInOrder[i]];
      if (b != null) {
        reordered.add(
          JournalBlock(
            id: b.id,
            pageId: b.pageId,
            type: b.type,
            orderIndex: i,
            payload: b.payload,
            createdAt: b.createdAt,
          ),
        );
      }
    }
    blocksByPageId[pageId] = reordered;
  }
}
