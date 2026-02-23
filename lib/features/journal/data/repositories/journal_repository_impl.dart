import 'package:uuid/uuid.dart';

import 'package:lord_of_idea/features/journal/data/local/journal_database.dart';
import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';

/// 基于 drift 的 JournalRepository 实现。
class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._db);

  final JournalDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<Journal>> getAllJournals() => _db.getAllJournals();

  @override
  Future<Journal?> getJournalById(String id) => _db.getJournalById(id);

  @override
  Future<Journal> createJournal({String? title}) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final journal = Journal(
      id: id,
      title: title ?? '',
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertJournal(journal);
    final firstPage = JournalPage(
      id: _uuid.v4(),
      journalId: id,
      orderIndex: 0,
      createdAt: now,
    );
    await _db.insertJournalPage(firstPage);
    return journal;
  }

  @override
  Future<void> updateJournal(Journal journal) async {
    final updated = journal.copyWith(updatedAt: DateTime.now().toUtc());
    await _db.updateJournal(updated);
  }

  @override
  Future<void> deleteJournal(String id) async {
    final pages = await _db.getPagesByJournalId(id);
    for (final page in pages) {
      await _db.deleteBlocksByPageId(page.id);
    }
    await _db.deletePagesByJournalId(id);
    await _db.deleteJournalById(id);
  }

  @override
  Future<List<JournalPage>> getPages(String journalId) =>
      _db.getPagesByJournalId(journalId);

  @override
  Future<JournalPage> addPage(String journalId) async {
    final pages = await _db.getPagesByJournalId(journalId);
    final nextIndex = pages.isEmpty ? 0 : pages.length;
    final now = DateTime.now().toUtc();
    final page = JournalPage(
      id: _uuid.v4(),
      journalId: journalId,
      orderIndex: nextIndex,
      createdAt: now,
    );
    await _db.insertJournalPage(page);
    return page;
  }

  @override
  Future<List<JournalBlock>> getBlocks(String pageId) =>
      _db.getBlocksByPageId(pageId);

  @override
  Future<JournalBlock> addBlock(String pageId, JournalBlock block) async {
    final blocks = await _db.getBlocksByPageId(pageId);
    final nextIndex = blocks.isEmpty ? 0 : blocks.length;
    final toInsert = JournalBlock(
      id: block.id,
      pageId: pageId,
      type: block.type,
      orderIndex: nextIndex,
      payload: block.payload,
      createdAt: block.createdAt,
    );
    await _db.insertJournalBlock(toInsert);
    final page = await _db.getPageById(pageId);
    if (page != null) {
      final journal = await _db.getJournalById(page.journalId);
      if (journal != null) {
        await _db.updateJournal(
          journal.copyWith(updatedAt: DateTime.now().toUtc()),
        );
      }
    }
    return toInsert;
  }

  @override
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {
    for (var i = 0; i < blockIdsInOrder.length; i++) {
      await _db.updateBlockOrder(blockIdsInOrder[i], i);
    }
  }
}
