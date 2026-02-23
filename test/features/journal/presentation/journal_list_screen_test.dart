import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:lord_of_idea/app.dart';
import 'package:lord_of_idea/core/di/local_storage_provider.dart';
import 'package:lord_of_idea/core/di/local_storage_service.dart';
import 'package:lord_of_idea/core/router/app_router.dart';
import 'package:lord_of_idea/features/journal/data/journal_providers.dart';
import 'package:lord_of_idea/features/journal/presentation/journal_list_screen.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('P2-3 JournalListScreen', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpApp(
      WidgetTester tester, {
      List<Journal>? journalList,
      JournalRepository? journalRepository,
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final overrides = [
        localStorageProvider.overrideWithValue(storage),
        appRouterProvider.overrideWithValue(
          createAppRouter(initialLocation: '/journal'),
        ),
        if (journalList != null)
          journalListProvider.overrideWith((ref) => Future.value(journalList)),
        if (journalRepository != null)
          journalRepositoryProvider.overrideWithValue(journalRepository),
      ];
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const MyApp()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('P2-3-W1: 含「创建手账」按钮与网格区域', (WidgetTester tester) async {
      await pumpApp(
        tester,
        journalList: [
          Journal(
            id: 'j1',
            title: 'One',
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 2),
          ),
        ],
      );
      expect(
        find.byKey(const Key('journal_list_create_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal_list_grid')), findsOneWidget);
    });

    testWidgets('P2-3-W2: 列表为空时仅展示创建按钮，无长段占位文案', (WidgetTester tester) async {
      await pumpApp(tester, journalList: []);
      expect(
        find.byKey(const Key('journal_list_create_button')),
        findsOneWidget,
      );
      expect(find.byType(JournalListScreen), findsOneWidget);
    });

    testWidgets('P2-3-W3: 列表有数据时以卡片形式展示封面与标题', (WidgetTester tester) async {
      const id = 'journal-1';
      const title = 'My First Journal';
      await pumpApp(
        tester,
        journalList: [
          Journal(
            id: id,
            title: title,
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 2),
          ),
        ],
      );
      expect(find.byKey(Key('journal_card_title_$id')), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.byKey(const Key('journal_list_grid')), findsOneWidget);
    });

    testWidgets('P2-3-W4: 点击手帐项跳转至 /journal/:id', (WidgetTester tester) async {
      const id = 'journal-tap-id';
      final journal = Journal(
        id: id,
        title: 'Tap Me',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );
      final mockRepo = _ListMockRepo(journalById: journal, list: [journal]);
      await pumpApp(
        tester,
        journalList: [journal],
        journalRepository: mockRepo,
      );
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig
              as GoRouter;
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/journal/$id',
      );
    });

    testWidgets('P2-3-W5: 路由 /journal 解析为 JournalListScreen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, journalList: []);
      expect(find.byType(JournalListScreen), findsOneWidget);
    });

    testWidgets('P2-3-W6: 点击创建后先弹标题输入框，确认后创建并进入手帐', (
      WidgetTester tester,
    ) async {
      const newId = 'new-journal-id';
      final mockRepo = _MockJournalRepository(
        createResult: Journal(
          id: newId,
          title: 'Entered Title',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
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
            journalListProvider.overrideWith((ref) => Future.value([])),
            journalRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('journal_list_create_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('journal_create_title_field')),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('journal_create_title_field')),
        'Entered Title',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final router =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig
              as GoRouter;
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/journal/$newId',
      );
    });

    testWidgets('P2-8-W1: 列表按时间顺序展示（最新在前）', (WidgetTester tester) async {
      const newestTitle = 'NewestJournal';
      const oldestTitle = 'OldestJournal';
      await pumpApp(
        tester,
        journalList: [
          Journal(
            id: 'id-new',
            title: newestTitle,
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 3),
          ),
          Journal(
            id: 'id-old',
            title: oldestTitle,
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 2),
          ),
        ],
      );
      expect(find.byType(JournalListScreen), findsOneWidget);
      expect(find.text(newestTitle), findsOneWidget);
      expect(find.text(oldestTitle), findsOneWidget);
      final firstCard = find.byType(Card).at(0);
      expect(
        find.descendant(of: firstCard, matching: find.text(newestTitle)),
        findsOneWidget,
      );
    });
  });
}

class _ListMockRepo implements JournalRepository {
  _ListMockRepo({this.journalById, required this.list});

  final Journal? journalById;
  final List<Journal> list;

  @override
  Future<Journal?> getJournalById(String id) async => journalById;

  @override
  Future<List<Journal>> getAllJournals() async => list;

  @override
  Future<Journal> createJournal({String? title}) async =>
      throw UnimplementedError();

  @override
  Future<void> updateJournal(Journal journal) async {}

  @override
  Future<void> deleteJournal(String id) async {}

  @override
  Future<List<JournalPage>> getPages(String journalId) async => [];

  @override
  Future<JournalPage> addPage(String journalId) async =>
      throw UnimplementedError();

  @override
  Future<List<JournalBlock>> getBlocks(String pageId) async => [];

  @override
  Future<JournalBlock> addBlock(String pageId, JournalBlock block) async =>
      throw UnimplementedError();

  @override
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {}
}

class _MockJournalRepository implements JournalRepository {
  _MockJournalRepository({required this.createResult});

  final Journal createResult;

  @override
  Future<Journal> createJournal({String? title}) async => createResult;

  @override
  Future<List<Journal>> getAllJournals() async => [];

  @override
  Future<Journal?> getJournalById(String id) async =>
      id == createResult.id ? createResult : null;

  @override
  Future<void> updateJournal(Journal journal) async {}

  @override
  Future<void> deleteJournal(String id) async {}

  @override
  Future<List<JournalPage>> getPages(String journalId) async => [];

  @override
  Future<JournalPage> addPage(String journalId) async =>
      throw UnimplementedError();

  @override
  Future<List<JournalBlock>> getBlocks(String pageId) async => [];

  @override
  Future<JournalBlock> addBlock(String pageId, JournalBlock block) async =>
      throw UnimplementedError();

  @override
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {}
}
