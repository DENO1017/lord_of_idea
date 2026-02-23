import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lord_of_idea/features/journal/data/local/journal_database.dart';
import 'package:lord_of_idea/features/journal/domain/block_editor.dart';
import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:lord_of_idea/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';

/// 手帐数据库单例。应用内使用默认路径；测试可通过 override 注入内存库。
final journalDatabaseProvider = Provider<JournalDatabase>((ref) {
  return JournalDatabase();
});

/// 手帐仓储。依赖 [journalDatabaseProvider]。
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final db = ref.watch(journalDatabaseProvider);
  return JournalRepositoryImpl(db);
});

/// 块编辑：添加文本块、插入工具结果、块排序。依赖 [journalRepositoryProvider]。
final blockEditorProvider = Provider<BlockEditor>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return BlockEditor(repo);
});

/// 手帐列表（按 updatedAt 倒序）。创建/删除后需 invalidate 以刷新。
final journalListProvider = FutureProvider<List<Journal>>((ref) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getAllJournals();
});

/// 指定 id 的手帐；不存在时为 null。
final journalDetailProvider = FutureProvider.family<Journal?, String>((
  ref,
  journalId,
) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getJournalById(journalId);
});

/// 指定手帐下的页，按 orderIndex 排序。
final journalPagesProvider = FutureProvider.family<List<JournalPage>, String>((
  ref,
  journalId,
) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getPages(journalId);
});

/// 指定页下的块，按 orderIndex 排序。
final journalBlocksProvider = FutureProvider.family<List<JournalBlock>, String>(
  (ref, pageId) async {
    final repo = ref.watch(journalRepositoryProvider);
    return repo.getBlocks(pageId);
  },
);
