/// 手帐页面实体。
class JournalPage {
  const JournalPage({
    required this.id,
    required this.journalId,
    this.title,
    required this.orderIndex,
    required this.createdAt,
  });

  final String id;
  final String journalId;
  final String? title;
  final int orderIndex;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'journalId': journalId,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
    if (title != null) map['title'] = title;
    return map;
  }

  factory JournalPage.fromJson(Map<String, dynamic> json) {
    return JournalPage(
      id: json['id'] as String,
      journalId: json['journalId'] as String,
      title: json['title'] as String?,
      orderIndex: json['orderIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalPage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          journalId == other.journalId &&
          orderIndex == other.orderIndex &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, journalId, orderIndex, createdAt);
}
