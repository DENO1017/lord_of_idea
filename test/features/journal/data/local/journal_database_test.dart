import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/features/journal/data/local/journal_database.dart';
import 'package:path/path.dart' as p;
import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:lord_of_idea/shared/models/journal.dart';
import 'package:lord_of_idea/shared/models/journal_block.dart';
import 'package:lord_of_idea/shared/models/journal_page.dart';

void main() {
  late JournalDatabase db;

  setUp(() {
    db = JournalDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('JournalPage', () {
    test(
      'P2-1-U2: 含 journalId、orderIndex；写入 DAO 后按 journalId 查询且 order 正确',
      () async {
        final journal = Journal(
          id: 'j-u2',
          title: 'U2',
          createdAt: DateTime.utc(2026, 2, 23),
          updatedAt: DateTime.utc(2026, 2, 23),
        );
        await db.insertJournal(journal);
        final page0 = JournalPage(
          id: 'p-u2-0',
          journalId: 'j-u2',
          orderIndex: 0,
          createdAt: DateTime.utc(2026, 2, 23),
        );
        final page1 = JournalPage(
          id: 'p-u2-1',
          journalId: 'j-u2',
          orderIndex: 1,
          createdAt: DateTime.utc(2026, 2, 23),
        );
        await db.insertJournalPage(page0);
        await db.insertJournalPage(page1);
        final pages = await db.getPagesByJournalId('j-u2');
        expect(pages.length, 2);
        expect(pages[0].orderIndex, 0);
        expect(pages[0].id, 'p-u2-0');
        expect(pages[1].orderIndex, 1);
        expect(pages[1].id, 'p-u2-1');
      },
    );
  });

  group('JournalBlock', () {
    test('P2-1-U3: text 块与 dice 块写入后读出，type 与 payload 解析正确', () async {
      final journal = Journal(
        id: 'j-u3',
        title: 'U3',
        createdAt: DateTime.utc(2026, 2, 23),
        updatedAt: DateTime.utc(2026, 2, 23),
      );
      await db.insertJournal(journal);
      final page = JournalPage(
        id: 'p-u3',
        journalId: 'j-u3',
        orderIndex: 0,
        createdAt: DateTime.utc(2026, 2, 23),
      );
      await db.insertJournalPage(page);

      final textPayload = jsonEncode({'content': '你好世界'});
      final textBlock = JournalBlock(
        id: 'b-u3-text',
        pageId: 'p-u3',
        type: 'text',
        orderIndex: 0,
        payload: textPayload,
        createdAt: DateTime.utc(2026, 2, 23),
      );
      await db.insertJournalBlock(textBlock);

      final dicePayload = jsonEncode({
        'type': 'dice',
        'createdAt': '2026-02-23T10:00:00.000Z',
        'expression': '2d6',
        'rolls': [
          {'faces': 6, 'value': 4},
          {'faces': 6, 'value': 2},
        ],
        'total': 6,
      });
      final diceBlock = JournalBlock(
        id: 'b-u3-dice',
        pageId: 'p-u3',
        type: 'dice',
        orderIndex: 1,
        payload: dicePayload,
        createdAt: DateTime.utc(2026, 2, 23),
      );
      await db.insertJournalBlock(diceBlock);

      final blocks = await db.getBlocksByPageId('p-u3');
      expect(blocks.length, 2);
      expect(blocks[0].type, 'text');
      expect(blocks[0].payload, textPayload);
      final textContent = jsonDecode(blocks[0].payload) as Map<String, dynamic>;
      expect(textContent['content'], '你好世界');
      expect(blocks[1].type, 'dice');
      expect(blocks[1].payload, dicePayload);
    });
  });

  group('DiceResult payload', () {
    test(
      'P2-1-U4: 块 payload 为 DiceResult.toJson() 时，读出解析为 DiceResult 与写入前一致',
      () async {
        final journal = Journal(
          id: 'j-u4',
          title: 'U4',
          createdAt: DateTime.utc(2026, 2, 23),
          updatedAt: DateTime.utc(2026, 2, 23),
        );
        await db.insertJournal(journal);
        final page = JournalPage(
          id: 'p-u4',
          journalId: 'j-u4',
          orderIndex: 0,
          createdAt: DateTime.utc(2026, 2, 23),
        );
        await db.insertJournalPage(page);

        final diceResult = DiceResult(
          createdAt: DateTime.utc(2026, 2, 23, 10, 0),
          expression: '1d20+5',
          rolls: [const SingleRoll(faces: 20, value: 12)],
          modifier: 5,
          total: 17,
        );
        final payloadStr = jsonEncode(diceResult.toJson());
        final block = JournalBlock(
          id: 'b-u4',
          pageId: 'p-u4',
          type: 'dice',
          orderIndex: 0,
          payload: payloadStr,
          createdAt: DateTime.utc(2026, 2, 23),
        );
        await db.insertJournalBlock(block);

        final blocks = await db.getBlocksByPageId('p-u4');
        expect(blocks.length, 1);
        final payloadMap =
            jsonDecode(blocks[0].payload) as Map<String, dynamic>;
        final restored = DiceResult.fromJson(payloadMap);
        expect(restored.expression, diceResult.expression);
        expect(restored.rolls.length, diceResult.rolls.length);
        expect(restored.rolls[0].faces, diceResult.rolls[0].faces);
        expect(restored.rolls[0].value, diceResult.rolls[0].value);
        expect(restored.modifier, diceResult.modifier);
        expect(restored.total, diceResult.total);
        expect(restored.createdAt, diceResult.createdAt);
      },
    );
  });

  group('drift 迁移', () {
    test('P2-1-U5: 插入手帐、一页、一块后关闭再打开，仍可查询到相同数据', () async {
      final prev = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(() {
        driftRuntimeOptions.dontWarnAboutMultipleDatabases = prev;
      });
      final dir = await Directory.systemTemp.createTemp('drift_u5');
      final file = File(p.join(dir.path, 'journal.db'));
      final db1 = JournalDatabase(NativeDatabase(file));
      final journal = Journal(
        id: 'j-u5',
        title: 'U5 手账',
        createdAt: DateTime.utc(2026, 2, 23),
        updatedAt: DateTime.utc(2026, 2, 23),
      );
      await db1.insertJournal(journal);
      final page = JournalPage(
        id: 'p-u5',
        journalId: 'j-u5',
        orderIndex: 0,
        createdAt: DateTime.utc(2026, 2, 23),
      );
      await db1.insertJournalPage(page);
      final block = JournalBlock(
        id: 'b-u5',
        pageId: 'p-u5',
        type: 'text',
        orderIndex: 0,
        payload: jsonEncode({'content': 'U5 内容'}),
        createdAt: DateTime.utc(2026, 2, 23),
      );
      await db1.insertJournalBlock(block);
      await db1.close();

      final db2 = JournalDatabase(NativeDatabase(file));
      final j = await db2.getJournalById('j-u5');
      expect(j, isNotNull);
      expect(j!.title, 'U5 手账');
      final pages = await db2.getPagesByJournalId('j-u5');
      expect(pages.length, 1);
      expect(pages[0].orderIndex, 0);
      final blocks = await db2.getBlocksByPageId('p-u5');
      expect(blocks.length, 1);
      expect(blocks[0].type, 'text');
      expect(jsonDecode(blocks[0].payload)['content'], 'U5 内容');
      await db2.close();
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });
}
