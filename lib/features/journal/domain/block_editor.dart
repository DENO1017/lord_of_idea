import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:lord_of_idea/features/journal/domain/repositories/journal_repository.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/tool_result.dart';

/// 块编辑：添加文本块、插入工具结果块、块排序。委托 [JournalRepository] 持久化。
class BlockEditor {
  BlockEditor(this._repo);

  final JournalRepository _repo;
  static const _uuid = Uuid();

  /// 在页尾追加 type=text 的块，payload 为 {"content": content}。
  Future<JournalBlock> appendTextBlock(String pageId, String content) async {
    final now = DateTime.now().toUtc();
    final payload = jsonEncode(<String, dynamic>{'content': content});
    final block = JournalBlock(
      id: _uuid.v4(),
      pageId: pageId,
      type: 'text',
      orderIndex: 0,
      payload: payload,
      createdAt: now,
    );
    return _repo.addBlock(pageId, block);
  }

  /// 在页尾插入工具结果块，type 取 [result.type]，payload 为 result.toJson()。
  Future<JournalBlock> insertToolResultBlock(
    String pageId,
    ToolResult result,
  ) async {
    final payload = jsonEncode(result.toJson());
    final block = JournalBlock(
      id: _uuid.v4(),
      pageId: pageId,
      type: result.type,
      orderIndex: 0,
      payload: payload,
      createdAt: result.createdAt,
    );
    return _repo.addBlock(pageId, block);
  }

  /// 重排指定页的块顺序；[blockIdsInOrder] 为新的块 id 顺序。
  Future<void> reorderBlocks(
    String pageId,
    List<String> blockIdsInOrder,
  ) async {
    await _repo.reorderBlocks(pageId, blockIdsInOrder);
  }
}
