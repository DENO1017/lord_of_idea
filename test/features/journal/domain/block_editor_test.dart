import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/journal/data/local/journal_database.dart';
import 'package:lord_of_idea/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:lord_of_idea/features/journal/domain/block_editor.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';

void main() {
  late JournalDatabase db;
  late JournalRepositoryImpl repo;
  late BlockEditor editor;

  setUp(() {
    db = JournalDatabase(NativeDatabase.memory());
    repo = JournalRepositoryImpl(db);
    editor = BlockEditor(repo);
  });

  tearDown(() async {
    await db.close();
  });

  group('P2-5 BlockEditor', () {
    test('P2-5-U1: appendTextBlock 在页尾追加 type=text 的块', () async {
      final journal = await repo.createJournal(title: 'Test');
      final pages = await repo.getPages(journal.id);
      final pageId = pages[0].id;

      final block = await editor.appendTextBlock(pageId, 'Hello block');

      expect(block.type, 'text');
      expect(block.pageId, pageId);
      final payload = jsonDecode(block.payload) as Map<String, dynamic>;
      expect(payload['content'], 'Hello block');

      final blocks = await repo.getBlocks(pageId);
      expect(blocks.length, 1);
      expect(blocks[0].id, block.id);
      expect(blocks[0].type, 'text');
      expect(jsonDecode(blocks[0].payload)['content'], 'Hello block');
    });

    test(
      'P2-5-U2: insertToolResultBlock(pageId, DiceResult) 写入 type=dice、payload=toJson()',
      () async {
        final journal = await repo.createJournal(title: 'Test');
        final pages = await repo.getPages(journal.id);
        final pageId = pages[0].id;

        final diceResult = DiceResult(
          createdAt: DateTime(2025, 1, 1).toUtc(),
          expression: '2d6',
          rolls: [
            const SingleRoll(faces: 6, value: 3),
            const SingleRoll(faces: 6, value: 4),
          ],
          total: 7,
        );

        final block = await editor.insertToolResultBlock(pageId, diceResult);

        expect(block.type, 'dice');
        expect(block.pageId, pageId);
        final payloadMap = jsonDecode(block.payload) as Map<String, dynamic>;
        final parsed = DiceResult.fromJson(payloadMap);
        expect(parsed.expression, diceResult.expression);
        expect(parsed.total, diceResult.total);
        expect(parsed.rolls.length, diceResult.rolls.length);

        final blocks = await repo.getBlocks(pageId);
        expect(blocks.length, 1);
        expect(blocks[0].type, 'dice');
        final fromDb = DiceResult.fromJson(
          jsonDecode(blocks[0].payload) as Map<String, dynamic>,
        );
        expect(fromDb.expression, '2d6');
        expect(fromDb.total, 7);
      },
    );
  });
}
