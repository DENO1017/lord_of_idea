import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/journal/data/local/journal_database.dart';
import 'package:lord_of_idea/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';

void main() {
  late JournalDatabase db;
  late JournalRepositoryImpl repo;

  setUp(() {
    db = JournalDatabase(NativeDatabase.memory());
    repo = JournalRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('P2-2 JournalRepository', () {
    test('P2-2-U1: createJournal 返回新 Journal 且 DB 可查；默认带一页', () async {
      final journal = await repo.createJournal(title: '测试手帐');
      expect(journal.id, isNotEmpty);
      expect(journal.title, '测试手帐');

      final found = await repo.getJournalById(journal.id);
      expect(found, isNotNull);
      expect(found!.id, journal.id);
      expect(found.title, journal.title);

      final pages = await repo.getPages(journal.id);
      expect(pages.length, 1);
      expect(pages[0].orderIndex, 0);
      expect(pages[0].journalId, journal.id);
    });

    test('P2-2-U2: updateJournal 更新 title/updatedAt', () async {
      final journal = await repo.createJournal(title: '原标题');
      final updatedAtBefore = journal.updatedAt;

      await repo.updateJournal(journal.copyWith(title: '新标题'));

      final found = await repo.getJournalById(journal.id);
      expect(found, isNotNull);
      expect(found!.title, '新标题');
      // updatedAt 应由实现更新（写库后读回，不早于更新前）
      expect(
        !found.updatedAt.isBefore(
          updatedAtBefore.subtract(Duration(seconds: 1)),
        ),
        isTrue,
      );
    });

    test('P2-2-U3: deleteJournal 后 getJournalById 为空，其页与块不可见', () async {
      final journal = await repo.createJournal(title: '待删');
      final pages = await repo.getPages(journal.id);
      expect(pages.length, 1);
      final pageId = pages[0].id;

      await repo.addBlock(
        pageId,
        JournalBlock(
          id: 'b1',
          pageId: pageId,
          type: 'text',
          orderIndex: 0,
          payload: '{"content":"x"}',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await repo.deleteJournal(journal.id);

      final found = await repo.getJournalById(journal.id);
      expect(found, isNull);
      final blocks = await repo.getBlocks(pageId);
      expect(blocks, isEmpty);
    });

    test('P2-2-U4: addPage 在指定手帐下追加页，orderIndex 递增', () async {
      final journal = await repo.createJournal(title: '多页');
      final page1 = await repo.addPage(journal.id);
      final page2 = await repo.addPage(journal.id);

      final pages = await repo.getPages(journal.id);
      expect(pages.length, 3); // 创建时 1 页 + 2 次 addPage
      expect(pages[0].orderIndex, 0);
      expect(pages[1].orderIndex, 1);
      expect(pages[2].orderIndex, 2);
      expect(page1.orderIndex, 1);
      expect(page2.orderIndex, 2);
    });

    test('P2-2-U5: addBlock 在指定页追加块；reorderBlocks 可更新块顺序', () async {
      final journal = await repo.createJournal(title: '块测试');
      final pages = await repo.getPages(journal.id);
      final pageId = pages[0].id;

      final now = DateTime.now().toUtc();
      final b1 = await repo.addBlock(
        pageId,
        JournalBlock(
          id: 'block-a',
          pageId: pageId,
          type: 'text',
          orderIndex: -1,
          payload: '{"content":"A"}',
          createdAt: now,
        ),
      );
      final b2 = await repo.addBlock(
        pageId,
        JournalBlock(
          id: 'block-b',
          pageId: pageId,
          type: 'text',
          orderIndex: -1,
          payload: '{"content":"B"}',
          createdAt: now,
        ),
      );

      var blocks = await repo.getBlocks(pageId);
      expect(blocks.length, 2);
      expect(blocks[0].orderIndex, 0);
      expect(blocks[1].orderIndex, 1);
      expect(blocks[0].id, b1.id);
      expect(blocks[1].id, b2.id);

      await repo.reorderBlocks(pageId, [b2.id, b1.id]);

      blocks = await repo.getBlocks(pageId);
      expect(blocks.length, 2);
      expect(blocks[0].id, b2.id);
      expect(blocks[1].id, b1.id);
      expect(blocks[0].orderIndex, 0);
      expect(blocks[1].orderIndex, 1);
    });
  });

  group('P2-8 手帐列表数据范围与按时间排序', () {
    test('P2-8-U1: getAllJournals 返回结果按 updatedAt 倒序', () async {
      final j1 = await repo.createJournal(title: 'J1');
      final j2 = await repo.createJournal(title: 'J2');
      final j3 = await repo.createJournal(title: 'J3');
      await repo.updateJournal(j1.copyWith(title: 'J1'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.updateJournal(j2.copyWith(title: 'J2'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.updateJournal(j3.copyWith(title: 'J3'));

      final list = await repo.getAllJournals();
      expect(list.length, 3);
      expect(list.map((j) => j.id).toSet(), {j1.id, j2.id, j3.id});
      for (var i = 1; i < list.length; i++) {
        expect(
          !list[i].updatedAt.isAfter(list[i - 1].updatedAt),
          isTrue,
          reason: '列表应按 updatedAt 倒序',
        );
      }
    });

    test('P2-8-U2: 列表数据来源包含本地手帐且按时间排序', () async {
      final j1 = await repo.createJournal(title: '本地1');
      final j2 = await repo.createJournal(title: '本地2');
      final list = await repo.getAllJournals();
      expect(list.length, 2);
      final ids = list.map((j) => j.id).toSet();
      expect(ids, contains(j1.id));
      expect(ids, contains(j2.id));
      for (var i = 1; i < list.length; i++) {
        expect(
          !list[i].updatedAt.isAfter(list[i - 1].updatedAt),
          isTrue,
          reason: '列表应按 updatedAt 倒序',
        );
      }
    });
  });
}
