import 'package:lord_of_idea/shared/models/tool_result.dart';

/// 简易占卜（塔罗）工具结果。
class DivinationResult extends ToolResult {
  const DivinationResult({
    required super.createdAt,
    required this.deckId,
    required this.cardId,
    required this.cardName,
    required this.reversed,
    required this.meaning,
    this.imagePathOrUrl,
  });

  static const String typeValue = 'divination';

  @override
  String get type => typeValue;

  final String deckId;
  final String cardId;
  final String cardName;
  final bool reversed;
  final String meaning;
  final String? imagePathOrUrl;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'deckId': deckId,
      'cardId': cardId,
      'cardName': cardName,
      'reversed': reversed,
      'meaning': meaning,
    };
    if (imagePathOrUrl != null) map['imagePathOrUrl'] = imagePathOrUrl;
    return map;
  }

  factory DivinationResult.fromJson(Map<String, dynamic> json) {
    return DivinationResult(
      createdAt: DateTime.parse(json['createdAt'] as String),
      deckId: json['deckId'] as String,
      cardId: json['cardId'] as String,
      cardName: json['cardName'] as String,
      reversed: json['reversed'] as bool,
      meaning: json['meaning'] as String,
      imagePathOrUrl: json['imagePathOrUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivinationResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          createdAt == other.createdAt &&
          deckId == other.deckId &&
          cardId == other.cardId &&
          cardName == other.cardName &&
          reversed == other.reversed &&
          meaning == other.meaning &&
          imagePathOrUrl == other.imagePathOrUrl;

  @override
  int get hashCode => Object.hash(
    type,
    createdAt,
    deckId,
    cardId,
    cardName,
    reversed,
    meaning,
    imagePathOrUrl,
  );
}
