import 'package:lord_of_idea/shared/models/tool_result.dart';

/// 诗签工具结果。
class PoemSlipResult extends ToolResult {
  const PoemSlipResult({
    required super.createdAt,
    required this.libraryId,
    required this.slipId,
    required this.content,
    this.extra,
  });

  static const String typeValue = 'poem_slip';

  @override
  String get type => typeValue;

  final String libraryId;
  final String slipId;
  final String content;
  final Map<String, dynamic>? extra;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'libraryId': libraryId,
      'slipId': slipId,
      'content': content,
    };
    if (extra != null && extra!.isNotEmpty) map['extra'] = extra;
    return map;
  }

  factory PoemSlipResult.fromJson(Map<String, dynamic> json) {
    return PoemSlipResult(
      createdAt: DateTime.parse(json['createdAt'] as String),
      libraryId: json['libraryId'] as String,
      slipId: json['slipId'] as String,
      content: json['content'] as String,
      extra: json['extra'] != null
          ? Map<String, dynamic>.from(json['extra'] as Map)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoemSlipResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          createdAt == other.createdAt &&
          libraryId == other.libraryId &&
          slipId == other.slipId &&
          content == other.content;

  @override
  int get hashCode => Object.hash(type, createdAt, libraryId, slipId, content);
}
