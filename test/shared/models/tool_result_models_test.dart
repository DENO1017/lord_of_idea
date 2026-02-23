import 'package:flutter_test/flutter_test.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

void main() {
  group('DiceResult', () {
    test(
      'P1-1-U1: toJson() 含 type、createdAt、expression、rolls、modifier、total，type 为 "dice"',
      () {
        final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
        final result = DiceResult(
          createdAt: createdAt,
          expression: '2d6+3',
          rolls: const [
            SingleRoll(faces: 6, value: 4),
            SingleRoll(faces: 6, value: 2),
          ],
          modifier: 3,
          total: 12,
        );
        final json = result.toJson();

        expect(json['type'], 'dice');
        expect(json['createdAt'], isA<String>());
        expect(json['expression'], '2d6+3');
        expect(json['rolls'], isA<List>());
        expect((json['rolls'] as List).length, 2);
        expect(json['modifier'], 3);
        expect(json['total'], 12);
      },
    );

    test('P1-1-U2: fromJson(上述 json) 还原为相等对象', () {
      final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
      final original = DiceResult(
        createdAt: createdAt,
        expression: '2d6+3',
        rolls: const [
          SingleRoll(faces: 6, value: 4),
          SingleRoll(faces: 6, value: 2),
        ],
        modifier: 3,
        total: 12,
      );
      final json = original.toJson();
      final restored = DiceResult.fromJson(json);

      expect(restored.type, original.type);
      expect(
        restored.createdAt.toUtc().toIso8601String(),
        original.createdAt.toUtc().toIso8601String(),
      );
      expect(restored.expression, original.expression);
      expect(restored.rolls.length, original.rolls.length);
      for (var i = 0; i < original.rolls.length; i++) {
        expect(restored.rolls[i].faces, original.rolls[i].faces);
        expect(restored.rolls[i].value, original.rolls[i].value);
      }
      expect(restored.modifier, original.modifier);
      expect(restored.total, original.total);
    });
  });

  group('PoemSlipResult', () {
    test('P1-1-U3: toJson/fromJson 往返一致，含 libraryId、slipId、content', () {
      final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
      const libraryId = 'default';
      const slipId = 'slip_001';
      const content = '春眠不觉晓，处处闻啼鸟。';
      final original = PoemSlipResult(
        createdAt: createdAt,
        libraryId: libraryId,
        slipId: slipId,
        content: content,
      );
      final json = original.toJson();
      final restored = PoemSlipResult.fromJson(json);

      expect(restored.type, original.type);
      expect(
        restored.createdAt.toUtc().toIso8601String(),
        original.createdAt.toUtc().toIso8601String(),
      );
      expect(restored.libraryId, libraryId);
      expect(restored.slipId, slipId);
      expect(restored.content, content);
    });
  });

  group('DivinationResult', () {
    test(
      'P1-1-U4: toJson/fromJson 往返一致，含 cardId、cardName、reversed、meaning',
      () {
        final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
        const deckId = 'rws';
        const cardId = 'rws_00';
        const cardName = '愚者';
        const reversed = false;
        const meaning = '新的开始，冒险与天真。';
        final original = DivinationResult(
          createdAt: createdAt,
          deckId: deckId,
          cardId: cardId,
          cardName: cardName,
          reversed: reversed,
          meaning: meaning,
        );
        final json = original.toJson();
        final restored = DivinationResult.fromJson(json);

        expect(restored.type, original.type);
        expect(
          restored.createdAt.toUtc().toIso8601String(),
          original.createdAt.toUtc().toIso8601String(),
        );
        expect(restored.deckId, deckId);
        expect(restored.cardId, cardId);
        expect(restored.cardName, cardName);
        expect(restored.reversed, reversed);
        expect(restored.meaning, meaning);
      },
    );
  });

  group('P1-9 序列化一致性', () {
    test('P1-9-U1: DiceResult toJson→fromJson 关键字段与原始一致', () {
      final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
      final original = DiceResult(
        createdAt: createdAt,
        expression: '2d6+3',
        rolls: const [
          SingleRoll(faces: 6, value: 4),
          SingleRoll(faces: 6, value: 2),
        ],
        modifier: 3,
        total: 12,
      );
      final restored = DiceResult.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(
        restored.createdAt.toUtc().toIso8601String(),
        original.createdAt.toUtc().toIso8601String(),
      );
      expect(restored.expression, original.expression);
      expect(restored.rolls.length, original.rolls.length);
      for (var i = 0; i < original.rolls.length; i++) {
        expect(restored.rolls[i].faces, original.rolls[i].faces);
        expect(restored.rolls[i].value, original.rolls[i].value);
      }
      expect(restored.modifier, original.modifier);
      expect(restored.total, original.total);
    });

    test('P1-9-U1: PoemSlipResult toJson→fromJson 关键字段与原始一致', () {
      final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
      final original = PoemSlipResult(
        createdAt: createdAt,
        libraryId: 'default',
        slipId: 'slip_001',
        content: '春眠不觉晓，处处闻啼鸟。',
      );
      final restored = PoemSlipResult.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(
        restored.createdAt.toUtc().toIso8601String(),
        original.createdAt.toUtc().toIso8601String(),
      );
      expect(restored.libraryId, original.libraryId);
      expect(restored.slipId, original.slipId);
      expect(restored.content, original.content);
    });

    test('P1-9-U1: DivinationResult toJson→fromJson 关键字段与原始一致', () {
      final createdAt = DateTime.utc(2025, 2, 22, 10, 0, 0);
      final original = DivinationResult(
        createdAt: createdAt,
        deckId: 'rws',
        cardId: 'rws_00',
        cardName: '愚者',
        reversed: false,
        meaning: '新的开始，冒险与天真。',
        imagePathOrUrl: null,
      );
      final restored = DivinationResult.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(
        restored.createdAt.toUtc().toIso8601String(),
        original.createdAt.toUtc().toIso8601String(),
      );
      expect(restored.deckId, original.deckId);
      expect(restored.cardId, original.cardId);
      expect(restored.cardName, original.cardName);
      expect(restored.reversed, original.reversed);
      expect(restored.meaning, original.meaning);
      expect(restored.imagePathOrUrl, original.imagePathOrUrl);
    });
  });
}
