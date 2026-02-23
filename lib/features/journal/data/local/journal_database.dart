import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:lord_of_idea/shared/models/journal.dart' as m;
import 'package:lord_of_idea/shared/models/journal_block.dart' as mb;
import 'package:lord_of_idea/shared/models/journal_page.dart' as mp;

part 'journal_database.g.dart';

@DataClassName('JournalRow')
class Journals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get coverPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('JournalPageRow')
class JournalPages extends Table {
  TextColumn get id => text()();
  TextColumn get journalId => text()();
  TextColumn get title => text().nullable()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('JournalBlockRow')
class JournalBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get pageId => text()();
  TextColumn get type => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Journals, JournalPages, JournalBlocks])
class JournalDatabase extends _$JournalDatabase {
  JournalDatabase([QueryExecutor? executor])
    : super(executor ?? _openExecutor());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  static QueryExecutor _openExecutor() {
    return LazyDatabase(() async {
      final dbDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbDir.path, 'journal.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  /// 插入手帐，返回插入行数。
  Future<int> insertJournal(m.Journal journal) {
    return into(journals).insert(
      JournalsCompanion.insert(
        id: journal.id,
        title: journal.title,
        createdAt: journal.createdAt,
        updatedAt: journal.updatedAt,
        coverPath: Value(journal.coverPath),
      ),
    );
  }

  /// 查询所有手帐，按 updatedAt 倒序。
  Future<List<m.Journal>> getAllJournals() async {
    final rows = await (select(
      journals,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return rows.map(_journalFromRow).toList();
  }

  /// 按 id 查询手帐。
  Future<m.Journal?> getJournalById(String id) async {
    final row = await (select(
      journals,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _journalFromRow(row) : null;
  }

  /// 更新手帐（如 title、updatedAt）。
  Future<int> updateJournal(m.Journal journal) {
    return (update(journals)..where((t) => t.id.equals(journal.id))).write(
      JournalsCompanion(
        title: Value(journal.title),
        updatedAt: Value(journal.updatedAt),
      ),
    );
  }

  /// 删除手帐（调用方需先级联删除页与块，或使用 [deleteJournalCascade]）。
  Future<int> deleteJournalById(String id) {
    return (delete(journals)..where((t) => t.id.equals(id))).go();
  }

  /// 按 journalId 删除所有页面。
  Future<int> deletePagesByJournalId(String journalId) {
    return (delete(
      journalPages,
    )..where((t) => t.journalId.equals(journalId))).go();
  }

  /// 按 pageId 删除所有块。
  Future<int> deleteBlocksByPageId(String pageId) {
    return (delete(journalBlocks)..where((t) => t.pageId.equals(pageId))).go();
  }

  /// 更新块的 orderIndex。
  Future<int> updateBlockOrder(String blockId, int orderIndex) {
    return (update(journalBlocks)..where((t) => t.id.equals(blockId))).write(
      JournalBlocksCompanion(orderIndex: Value(orderIndex)),
    );
  }

  /// 插入页面。
  Future<int> insertJournalPage(mp.JournalPage page) {
    return into(journalPages).insert(
      JournalPagesCompanion.insert(
        id: page.id,
        journalId: page.journalId,
        title: Value(page.title),
        orderIndex: page.orderIndex,
        createdAt: page.createdAt,
      ),
    );
  }

  /// 按 pageId 查询单页，不存在返回 null。
  Future<mp.JournalPage?> getPageById(String pageId) async {
    final row = await (select(
      journalPages,
    )..where((t) => t.id.equals(pageId))).getSingleOrNull();
    return row != null ? _pageFromRow(row) : null;
  }

  /// 按 journalId 查询页面，按 orderIndex 排序。
  Future<List<mp.JournalPage>> getPagesByJournalId(String journalId) async {
    final rows =
        await (select(journalPages)
              ..where((t) => t.journalId.equals(journalId))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    return rows.map(_pageFromRow).toList();
  }

  /// 插入块。
  Future<int> insertJournalBlock(mb.JournalBlock block) {
    return into(journalBlocks).insert(
      JournalBlocksCompanion.insert(
        id: block.id,
        pageId: block.pageId,
        type: block.type,
        orderIndex: block.orderIndex,
        payload: block.payload,
        createdAt: block.createdAt,
      ),
    );
  }

  /// 按 pageId 查询块，按 orderIndex 排序。
  Future<List<mb.JournalBlock>> getBlocksByPageId(String pageId) async {
    final rows =
        await (select(journalBlocks)
              ..where((t) => t.pageId.equals(pageId))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    return rows.map(_blockFromRow).toList();
  }

  m.Journal _journalFromRow(JournalRow row) {
    return m.Journal(
      id: row.id,
      title: row.title,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      coverPath: row.coverPath,
    );
  }

  mp.JournalPage _pageFromRow(JournalPageRow row) {
    return mp.JournalPage(
      id: row.id,
      journalId: row.journalId,
      title: row.title,
      orderIndex: row.orderIndex,
      createdAt: row.createdAt,
    );
  }

  mb.JournalBlock _blockFromRow(JournalBlockRow row) {
    return mb.JournalBlock.fromRow(
      id: row.id,
      pageId: row.pageId,
      type: row.type,
      orderIndex: row.orderIndex,
      payload: row.payload,
      createdAt: row.createdAt,
    );
  }
}
