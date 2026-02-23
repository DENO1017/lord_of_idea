import 'dart:math';

import 'package:lord_of_idea/shared/models/dice_result.dart';

/// 标准骰子面数（仅支持 d4/d6/d8/d10/d12/d20）。
const List<int> kAllowedFaces = [4, 6, 8, 10, 12, 20];

/// 解析后的骰子表达式：数量、面数、修正。
class ParsedDice {
  const ParsedDice({
    required this.count,
    required this.faces,
    required this.modifier,
  });

  final int count;
  final int faces;
  final int modifier;
}

/// 表达式解析结果：成功带 [ParsedDice]，失败带错误信息。
sealed class DiceParseResult {}

class DiceParseSuccess implements DiceParseResult {
  const DiceParseSuccess(this.value);
  final ParsedDice value;
}

class DiceParseFailure implements DiceParseResult {
  const DiceParseFailure(this.message);
  final String message;
}

/// 掷骰结果：成功返回 [DiceResult]，解析失败返回可展示错误。
sealed class DiceRollResult {}

class DiceRollSuccess implements DiceRollResult {
  const DiceRollSuccess(this.result);
  final DiceResult result;
}

class DiceRollParseError implements DiceRollResult {
  const DiceRollParseError(this.message);
  final String message;
}

/// 骰子表达式解析与掷骰。随机源可注入便于测试。
class DiceRoller {
  DiceRoller([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// 解析表达式 [expression]（如 "2d6+3"、"d20"）。
  /// 合法：数量 1～20，面数仅 4/6/8/10/12/20，修正 -999～+999。
  DiceParseResult parse(String expression) {
    final s = expression.trim();
    if (s.isEmpty) {
      return const DiceParseFailure('表达式不能为空');
    }
    // 格式: [数量]d[面数][+/-修正]，数量可省略（视为 1）
    final re = RegExp(r'^(\d*)d(\d+)([+-]\d+)?$', caseSensitive: false);
    final m = re.firstMatch(s);
    if (m == null) {
      return const DiceParseFailure('无效的骰子表达式格式');
    }
    final countStr = m.group(1);
    final facesStr = m.group(2)!;
    final modStr = m.group(3);

    final count = countStr == null || countStr.isEmpty
        ? 1
        : int.tryParse(countStr);
    if (count == null || count < 1 || count > 20) {
      return const DiceParseFailure('骰子数量须为 1～20');
    }
    final faces = int.tryParse(facesStr);
    if (faces == null || !kAllowedFaces.contains(faces)) {
      return const DiceParseFailure('仅支持 d4/d6/d8/d10/d12/d20');
    }
    int modifier = 0;
    if (modStr != null && modStr.isNotEmpty) {
      final modVal = int.tryParse(modStr);
      if (modVal == null || modVal < -999 || modVal > 999) {
        return const DiceParseFailure('修正值须在 -999～+999 之间');
      }
      modifier = modVal;
    }
    return DiceParseSuccess(
      ParsedDice(count: count, faces: faces, modifier: modifier),
    );
  }

  static String _buildExpression(ParsedDice parsed) {
    final base = '${parsed.count}d${parsed.faces}';
    if (parsed.modifier == 0) return base;
    return parsed.modifier > 0
        ? '$base+${parsed.modifier}'
        : '$base${parsed.modifier}';
  }

  /// d100（2d10）合计：十位 10 视为 0，个位 10 视为 10；双 10 为 100。结果 1～100。
  static int _d100Total(int tensDigit, int onesDigit) {
    final t = tensDigit == 10 ? 0 : tensDigit;
    final o = onesDigit == 10 ? 10 : onesDigit;
    final v = t * 10 + o;
    return v == 0 ? 100 : v;
  }

  /// 按解析结果掷骰，生成 [DiceResult]。
  /// 特殊规则：2d10（d100）时两颗 d10 分别作为十位与个位，结果为 1～100，而非两数相加。
  DiceResult rollParsed(ParsedDice parsed, {String? expression}) {
    final rolls = List<SingleRoll>.generate(
      parsed.count,
      (_) => SingleRoll(
        faces: parsed.faces,
        value: _random.nextInt(parsed.faces) + 1,
      ),
    );
    final bool isD100 =
        parsed.count == 2 && parsed.faces == 10 && parsed.modifier == 0;
    final int total = isD100
        ? _d100Total(rolls[0].value, rolls[1].value)
        : rolls.fold<int>(0, (a, r) => a + r.value) + parsed.modifier;
    final createdAt = DateTime.now().toUtc();
    return DiceResult(
      createdAt: createdAt,
      expression: expression ?? _buildExpression(parsed),
      rolls: rolls,
      modifier: parsed.modifier == 0 ? null : parsed.modifier,
      total: total,
    );
  }

  /// 解析并掷骰；若解析失败返回 [DiceRollParseError]，否则返回 [DiceRollSuccess]。
  DiceRollResult roll(String expression) {
    final parsed = parse(expression);
    switch (parsed) {
      case DiceParseSuccess(:final value):
        final result = rollParsed(value, expression: expression.trim());
        return DiceRollSuccess(result);
      case DiceParseFailure(:final message):
        return DiceRollParseError(message);
    }
  }
}
