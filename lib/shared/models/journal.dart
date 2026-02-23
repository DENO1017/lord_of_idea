/// 手帐实体。
class Journal {
  const Journal({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.coverPath,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverPath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
    if (coverPath != null) map['coverPath'] = coverPath;
    return map;
  }

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      coverPath: json['coverPath'] as String?,
    );
  }

  Journal copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverPath,
  }) {
    return Journal(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverPath: coverPath ?? this.coverPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Journal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          coverPath == other.coverPath;

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt, coverPath);
}
