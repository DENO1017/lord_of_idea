/// 手帐块实体。payload 为 JSON 字符串，与 P1 工具结果 toJson 一致。
class JournalBlock {
  const JournalBlock({
    required this.id,
    required this.pageId,
    required this.type,
    required this.orderIndex,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String pageId;

  /// 块类型：`text` | `dice` | `poem_slip` | `divination`
  final String type;
  final int orderIndex;

  /// JSON 字符串；text 时为 {"content":"..."}，工具块为对应 Result.toJson()
  final String payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pageId': pageId,
      'type': type,
      'orderIndex': orderIndex,
      'payload': payload,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory JournalBlock.fromJson(Map<String, dynamic> json) {
    return JournalBlock(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      type: json['type'] as String,
      orderIndex: json['orderIndex'] as int,
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从 DB 行还原：type 与 payload 与 P1 工具结果一致时可解析。
  factory JournalBlock.fromRow({
    required String id,
    required String pageId,
    required String type,
    required int orderIndex,
    required String payload,
    required DateTime createdAt,
  }) {
    return JournalBlock(
      id: id,
      pageId: pageId,
      type: type,
      orderIndex: orderIndex,
      payload: payload,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalBlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pageId == other.pageId &&
          type == other.type &&
          orderIndex == other.orderIndex &&
          payload == other.payload &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, pageId, type, orderIndex, payload, createdAt);
}
