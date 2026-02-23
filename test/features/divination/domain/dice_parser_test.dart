import 'package:lord_of_idea/features/divination/domain/services/dice_roller.dart';
import 'package:test/test.dart';

void main() {
  late DiceRoller roller;

  setUp(() {
    roller = DiceRoller();
  });

  group('P1-2 表达式解析', () {
    test('P1-2-U1: 解析 "2d6+3" 得到 count=2, faces=6, modifier=3', () {
      final result = roller.parse('2d6+3');
      expect(result, isA<DiceParseSuccess>());
      final success = result as DiceParseSuccess;
      expect(success.value.count, 2);
      expect(success.value.faces, 6);
      expect(success.value.modifier, 3);
    });

    test('P1-2-U2: 解析 "d20" 得到 count=1, faces=20, modifier=0', () {
      final result = roller.parse('d20');
      expect(result, isA<DiceParseSuccess>());
      final success = result as DiceParseSuccess;
      expect(success.value.count, 1);
      expect(success.value.faces, 20);
      expect(success.value.modifier, 0);
    });

    test('P1-2-U3: 解析非法字符串（如 "d"、"0d6"）返回错误或 throws', () {
      final dResult = roller.parse('d');
      expect(dResult, isA<DiceParseFailure>());
      expect((dResult as DiceParseFailure).message, isNotEmpty);

      final zeroResult = roller.parse('0d6');
      expect(zeroResult, isA<DiceParseFailure>());
      expect((zeroResult as DiceParseFailure).message, isNotEmpty);

      final invalidFaces = roller.parse('2d7');
      expect(invalidFaces, isA<DiceParseFailure>());
      expect((invalidFaces as DiceParseFailure).message, isNotEmpty);

      final badFormat = roller.parse('2d6+3d8');
      expect(badFormat, isA<DiceParseFailure>());
      expect((badFormat as DiceParseFailure).message, isNotEmpty);
    });
  });
}
