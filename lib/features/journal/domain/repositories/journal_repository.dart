import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';

/// 手帐/页/块仓储接口。列表按 updatedAt 倒序，页按 orderIndex 排序，块按 orderIndex 排序。
abstract interface class JournalRepository {
  /// 所有手帐（数据来源包含本地手帐与共享手帐，若已接入则合并后去重），按 updatedAt 倒序。
  Future<List<Journal>> getAllJournals();

  /// 按 id 查手帐，不存在返回 null。
  Future<Journal?> getJournalById(String id);

  /// 创建手帐（自动创建第一页 orderIndex 0），返回新手帐。
  Future<Journal> createJournal({String? title});

  /// 更新手帐（如 title），updatedAt 由实现更新。
  Future<void> updateJournal(Journal journal);

  /// 删除手帐并级联删除其页与块。
  Future<void> deleteJournal(String id);

  /// 指定手帐下的页，按 orderIndex 排序。
  Future<List<JournalPage>> getPages(String journalId);

  /// 在指定手帐下追加一页，orderIndex 递增。
  Future<JournalPage> addPage(String journalId);

  /// 指定页下的块，按 orderIndex 排序。
  Future<List<JournalBlock>> getBlocks(String pageId);

  /// 在指定页追加一块（orderIndex 由实现计算）。
  Future<JournalBlock> addBlock(String pageId, JournalBlock block);

  /// 重排指定页的块顺序；[blockIdsInOrder] 为新的块 id 顺序。
  Future<void> reorderBlocks(String pageId, List<String> blockIdsInOrder);
}
