import 'package:lord_of_idea/shared/models/tool_result.dart';

/// 单颗骰子一次掷出结果。
class SingleRoll {
  const SingleRoll({required this.faces, required this.value});

  final int faces;
  final int value;

  Map<String, dynamic> toJson() => {'faces': faces, 'value': value};

  factory SingleRoll.fromJson(Map<String, dynamic> json) {
    return SingleRoll(faces: json['faces'] as int, value: json['value'] as int);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleRoll &&
          runtimeType == other.runtimeType &&
          faces == other.faces &&
          value == other.value;

  @override
  int get hashCode => Object.hash(faces, value);
}

/// 骰子工具结果。
class DiceResult extends ToolResult {
  const DiceResult({
    required super.createdAt,
    required this.expression,
    required this.rolls,
    this.modifier,
    required this.total,
  });

  static const String typeValue = 'dice';

  @override
  String get type => typeValue;

  final String expression;
  final List<SingleRoll> rolls;
  final int? modifier;
  final int total;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'expression': expression,
      'rolls': rolls.map((r) => r.toJson()).toList(),
      'total': total,
    };
    if (modifier != null) map['modifier'] = modifier;
    return map;
  }

  factory DiceResult.fromJson(Map<String, dynamic> json) {
    return DiceResult(
      createdAt: DateTime.parse(json['createdAt'] as String),
      expression: json['expression'] as String,
      rolls: (json['rolls'] as List<dynamic>)
          .map((e) => SingleRoll.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifier: json['modifier'] as int?,
      total: json['total'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiceResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          createdAt == other.createdAt &&
          expression == other.expression &&
          _listEquals(rolls, other.rolls) &&
          modifier == other.modifier &&
          total == other.total;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    type,
    createdAt,
    expression,
    Object.hashAll(rolls),
    modifier,
    total,
  );
}
