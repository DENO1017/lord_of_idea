import 'dart:math';

import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';
import 'package:lord_of_idea/shared/models/dice_result.dart';
import 'package:test/test.dart';

void main() {
  group('P1-2 掷骰逻辑', () {
    test('P1-2-U4: 掷骰（固定 Random 种子）结果在 1..faces 范围内且 total 正确', () {
      final roller = DiceRoller(Random(42));
      final rollResult = roller.roll('2d6+3');
      expect(rollResult, isA<DiceRollSuccess>());
      final result = (rollResult as DiceRollSuccess).result;
      expect(result.rolls.length, 2);
      for (final r in result.rolls) {
        expect(r.faces, 6);
        expect(r.value, inInclusiveRange(1, 6));
      }
      final sumRolls = result.rolls.fold<int>(0, (a, r) => a + r.value);
      expect(result.total, sumRolls + 3);
    });

    test('P1-2-U5: 掷骰产出 DiceResult，含 expression、rolls、total', () {
      const expression = '3d6+1';
      final roller = DiceRoller(Random(0));
      final rollResult = roller.roll(expression);
      expect(rollResult, isA<DiceRollSuccess>());
      final result = (rollResult as DiceRollSuccess).result;
      expect(result, isA<DiceResult>());
      expect(result.expression, expression);
      expect(result.rolls, isNotEmpty);
      expect(result.rolls.length, 3);
      expect(result.total, greaterThanOrEqualTo(3 + 1));
      expect(result.total, lessThanOrEqualTo(18 + 1));
    });

    test('P1-11 / B-P1-1-001: 2d10（d100）结果为十位+个位 1～100，非两数相加', () {
      int d100Total(int tens, int ones) {
        final t = tens == 10 ? 0 : tens;
        final o = ones == 10 ? 10 : ones;
        final v = t * 10 + o;
        return v == 0 ? 100 : v;
      }

      final roller = DiceRoller(Random(123));
      final rollResult = roller.roll('2d10');
      expect(rollResult, isA<DiceRollSuccess>());
      final result = (rollResult as DiceRollSuccess).result;
      expect(result.rolls.length, 2);
      for (final r in result.rolls) {
        expect(r.faces, 10);
        expect(r.value, inInclusiveRange(1, 10));
      }
      expect(
        result.total,
        d100Total(result.rolls[0].value, result.rolls[1].value),
      );
      expect(result.total, inInclusiveRange(1, 100));
    });
  });
}
