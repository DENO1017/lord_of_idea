// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_database.dart';

// ignore_for_file: type=lint
class $JournalsTable extends Journals
    with TableInfo<$JournalsTable, JournalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    updatedAt,
    coverPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journals';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
    );
  }

  @override
  $JournalsTable createAlias(String alias) {
    return $JournalsTable(attachedDatabase, alias);
  }
}

class JournalRow extends DataClass implements Insertable<JournalRow> {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverPath;
  const JournalRow({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.coverPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    return map;
  }

  JournalsCompanion toCompanion(bool nullToAbsent) {
    return JournalsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
    );
  }

  factory JournalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'coverPath': serializer.toJson<String?>(coverPath),
    };
  }

  JournalRow copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> coverPath = const Value.absent(),
  }) => JournalRow(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
  );
  JournalRow copyWithCompanion(JournalsCompanion data) {
    return JournalRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverPath: $coverPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt, coverPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.coverPath == this.coverPath);
}

class JournalsCompanion extends UpdateCompanion<JournalRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> coverPath;
  final Value<int> rowid;
  const JournalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalsCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.coverPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JournalRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? coverPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (coverPath != null) 'cover_path': coverPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? coverPath,
    Value<int>? rowid,
  }) {
    return JournalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverPath: coverPath ?? this.coverPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverPath: $coverPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalPagesTable extends JournalPages
    with TableInfo<$JournalPagesTable, JournalPageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalIdMeta = const VerificationMeta(
    'journalId',
  );
  @override
  late final GeneratedColumn<String> journalId = GeneratedColumn<String>(
    'journal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    journalId,
    title,
    orderIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalPageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('journal_id')) {
      context.handle(
        _journalIdMeta,
        journalId.isAcceptableOrUnknown(data['journal_id']!, _journalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_journalIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalPageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalPageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      journalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalPagesTable createAlias(String alias) {
    return $JournalPagesTable(attachedDatabase, alias);
  }
}

class JournalPageRow extends DataClass implements Insertable<JournalPageRow> {
  final String id;
  final String journalId;
  final String? title;
  final int orderIndex;
  final DateTime createdAt;
  const JournalPageRow({
    required this.id,
    required this.journalId,
    this.title,
    required this.orderIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['journal_id'] = Variable<String>(journalId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalPagesCompanion toCompanion(bool nullToAbsent) {
    return JournalPagesCompanion(
      id: Value(id),
      journalId: Value(journalId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
    );
  }

  factory JournalPageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalPageRow(
      id: serializer.fromJson<String>(json['id']),
      journalId: serializer.fromJson<String>(json['journalId']),
      title: serializer.fromJson<String?>(json['title']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'journalId': serializer.toJson<String>(journalId),
      'title': serializer.toJson<String?>(title),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalPageRow copyWith({
    String? id,
    String? journalId,
    Value<String?> title = const Value.absent(),
    int? orderIndex,
    DateTime? createdAt,
  }) => JournalPageRow(
    id: id ?? this.id,
    journalId: journalId ?? this.journalId,
    title: title.present ? title.value : this.title,
    orderIndex: orderIndex ?? this.orderIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalPageRow copyWithCompanion(JournalPagesCompanion data) {
    return JournalPageRow(
      id: data.id.present ? data.id.value : this.id,
      journalId: data.journalId.present ? data.journalId.value : this.journalId,
      title: data.title.present ? data.title.value : this.title,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalPageRow(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, journalId, title, orderIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalPageRow &&
          other.id == this.id &&
          other.journalId == this.journalId &&
          other.title == this.title &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt);
}

class JournalPagesCompanion extends UpdateCompanion<JournalPageRow> {
  final Value<String> id;
  final Value<String> journalId;
  final Value<String?> title;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalPagesCompanion({
    this.id = const Value.absent(),
    this.journalId = const Value.absent(),
    this.title = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalPagesCompanion.insert({
    required String id,
    required String journalId,
    this.title = const Value.absent(),
    required int orderIndex,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       journalId = Value(journalId),
       orderIndex = Value(orderIndex),
       createdAt = Value(createdAt);
  static Insertable<JournalPageRow> custom({
    Expression<String>? id,
    Expression<String>? journalId,
    Expression<String>? title,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalId != null) 'journal_id': journalId,
      if (title != null) 'title': title,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalPagesCompanion copyWith({
    Value<String>? id,
    Value<String>? journalId,
    Value<String?>? title,
    Value<int>? orderIndex,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalPagesCompanion(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (journalId.present) {
      map['journal_id'] = Variable<String>(journalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalPagesCompanion(')
          ..write('id: $id, ')
          ..write('journalId: $journalId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalBlocksTable extends JournalBlocks
    with TableInfo<$JournalBlocksTable, JournalBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageId,
    type,
    orderIndex,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalBlocksTable createAlias(String alias) {
    return $JournalBlocksTable(attachedDatabase, alias);
  }
}

class JournalBlockRow extends DataClass implements Insertable<JournalBlockRow> {
  final String id;
  final String pageId;
  final String type;
  final int orderIndex;
  final String payload;
  final DateTime createdAt;
  const JournalBlockRow({
    required this.id,
    required this.pageId,
    required this.type,
    required this.orderIndex,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['page_id'] = Variable<String>(pageId);
    map['type'] = Variable<String>(type);
    map['order_index'] = Variable<int>(orderIndex);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JournalBlocksCompanion toCompanion(bool nullToAbsent) {
    return JournalBlocksCompanion(
      id: Value(id),
      pageId: Value(pageId),
      type: Value(type),
      orderIndex: Value(orderIndex),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory JournalBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalBlockRow(
      id: serializer.fromJson<String>(json['id']),
      pageId: serializer.fromJson<String>(json['pageId']),
      type: serializer.fromJson<String>(json['type']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pageId': serializer.toJson<String>(pageId),
      'type': serializer.toJson<String>(type),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JournalBlockRow copyWith({
    String? id,
    String? pageId,
    String? type,
    int? orderIndex,
    String? payload,
    DateTime? createdAt,
  }) => JournalBlockRow(
    id: id ?? this.id,
    pageId: pageId ?? this.pageId,
    type: type ?? this.type,
    orderIndex: orderIndex ?? this.orderIndex,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalBlockRow copyWithCompanion(JournalBlocksCompanion data) {
    return JournalBlockRow(
      id: data.id.present ? data.id.value : this.id,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      type: data.type.present ? data.type.value : this.type,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalBlockRow(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('type: $type, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pageId, type, orderIndex, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalBlockRow &&
          other.id == this.id &&
          other.pageId == this.pageId &&
          other.type == this.type &&
          other.orderIndex == this.orderIndex &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class JournalBlocksCompanion extends UpdateCompanion<JournalBlockRow> {
  final Value<String> id;
  final Value<String> pageId;
  final Value<String> type;
  final Value<int> orderIndex;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JournalBlocksCompanion({
    this.id = const Value.absent(),
    this.pageId = const Value.absent(),
    this.type = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalBlocksCompanion.insert({
    required String id,
    required String pageId,
    required String type,
    required int orderIndex,
    required String payload,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pageId = Value(pageId),
       type = Value(type),
       orderIndex = Value(orderIndex),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<JournalBlockRow> custom({
    Expression<String>? id,
    Expression<String>? pageId,
    Expression<String>? type,
    Expression<int>? orderIndex,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageId != null) 'page_id': pageId,
      if (type != null) 'type': type,
      if (orderIndex != null) 'order_index': orderIndex,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalBlocksCompanion copyWith({
    Value<String>? id,
    Value<String>? pageId,
    Value<String>? type,
    Value<int>? orderIndex,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalBlocksCompanion(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      type: type ?? this.type,
      orderIndex: orderIndex ?? this.orderIndex,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalBlocksCompanion(')
          ..write('id: $id, ')
          ..write('pageId: $pageId, ')
          ..write('type: $type, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$JournalDatabase extends GeneratedDatabase {
  _$JournalDatabase(QueryExecutor e) : super(e);
  $JournalDatabaseManager get managers => $JournalDatabaseManager(this);
  late final $JournalsTable journals = $JournalsTable(this);
  late final $JournalPagesTable journalPages = $JournalPagesTable(this);
  late final $JournalBlocksTable journalBlocks = $JournalBlocksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journals,
    journalPages,
    journalBlocks,
  ];
}

typedef $$JournalsTableCreateCompanionBuilder =
    JournalsCompanion Function({
      required String id,
      required String title,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> coverPath,
      Value<int> rowid,
    });
typedef $$JournalsTableUpdateCompanionBuilder =
    JournalsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> coverPath,
      Value<int> rowid,
    });

class $$JournalsTableFilterComposer
    extends Composer<_$JournalDatabase, $JournalsTable> {
  $$JournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalsTableOrderingComposer
    extends Composer<_$JournalDatabase, $JournalsTable> {
  $$JournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalsTableAnnotationComposer
    extends Composer<_$JournalDatabase, $JournalsTable> {
  $$JournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);
}

class $$JournalsTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $JournalsTable,
          JournalRow,
          $$JournalsTableFilterComposer,
          $$JournalsTableOrderingComposer,
          $$JournalsTableAnnotationComposer,
          $$JournalsTableCreateCompanionBuilder,
          $$JournalsTableUpdateCompanionBuilder,
          (
            JournalRow,
            BaseReferences<_$JournalDatabase, $JournalsTable, JournalRow>,
          ),
          JournalRow,
          PrefetchHooks Function()
        > {
  $$JournalsTableTableManager(_$JournalDatabase db, $JournalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverPath: coverPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> coverPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverPath: coverPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalsTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $JournalsTable,
      JournalRow,
      $$JournalsTableFilterComposer,
      $$JournalsTableOrderingComposer,
      $$JournalsTableAnnotationComposer,
      $$JournalsTableCreateCompanionBuilder,
      $$JournalsTableUpdateCompanionBuilder,
      (
        JournalRow,
        BaseReferences<_$JournalDatabase, $JournalsTable, JournalRow>,
      ),
      JournalRow,
      PrefetchHooks Function()
    >;
typedef $$JournalPagesTableCreateCompanionBuilder =
    JournalPagesCompanion Function({
      required String id,
      required String journalId,
      Value<String?> title,
      required int orderIndex,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$JournalPagesTableUpdateCompanionBuilder =
    JournalPagesCompanion Function({
      Value<String> id,
      Value<String> journalId,
      Value<String?> title,
      Value<int> orderIndex,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JournalPagesTableFilterComposer
    extends Composer<_$JournalDatabase, $JournalPagesTable> {
  $$JournalPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalId => $composableBuilder(
    column: $table.journalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalPagesTableOrderingComposer
    extends Composer<_$JournalDatabase, $JournalPagesTable> {
  $$JournalPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalId => $composableBuilder(
    column: $table.journalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalPagesTableAnnotationComposer
    extends Composer<_$JournalDatabase, $JournalPagesTable> {
  $$JournalPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get journalId =>
      $composableBuilder(column: $table.journalId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalPagesTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $JournalPagesTable,
          JournalPageRow,
          $$JournalPagesTableFilterComposer,
          $$JournalPagesTableOrderingComposer,
          $$JournalPagesTableAnnotationComposer,
          $$JournalPagesTableCreateCompanionBuilder,
          $$JournalPagesTableUpdateCompanionBuilder,
          (
            JournalPageRow,
            BaseReferences<
              _$JournalDatabase,
              $JournalPagesTable,
              JournalPageRow
            >,
          ),
          JournalPageRow,
          PrefetchHooks Function()
        > {
  $$JournalPagesTableTableManager(
    _$JournalDatabase db,
    $JournalPagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> journalId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalPagesCompanion(
                id: id,
                journalId: journalId,
                title: title,
                orderIndex: orderIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String journalId,
                Value<String?> title = const Value.absent(),
                required int orderIndex,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalPagesCompanion.insert(
                id: id,
                journalId: journalId,
                title: title,
                orderIndex: orderIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $JournalPagesTable,
      JournalPageRow,
      $$JournalPagesTableFilterComposer,
      $$JournalPagesTableOrderingComposer,
      $$JournalPagesTableAnnotationComposer,
      $$JournalPagesTableCreateCompanionBuilder,
      $$JournalPagesTableUpdateCompanionBuilder,
      (
        JournalPageRow,
        BaseReferences<_$JournalDatabase, $JournalPagesTable, JournalPageRow>,
      ),
      JournalPageRow,
      PrefetchHooks Function()
    >;
typedef $$JournalBlocksTableCreateCompanionBuilder =
    JournalBlocksCompanion Function({
      required String id,
      required String pageId,
      required String type,
      required int orderIndex,
      required String payload,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$JournalBlocksTableUpdateCompanionBuilder =
    JournalBlocksCompanion Function({
      Value<String> id,
      Value<String> pageId,
      Value<String> type,
      Value<int> orderIndex,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JournalBlocksTableFilterComposer
    extends Composer<_$JournalDatabase, $JournalBlocksTable> {
  $$JournalBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalBlocksTableOrderingComposer
    extends Composer<_$JournalDatabase, $JournalBlocksTable> {
  $$JournalBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalBlocksTableAnnotationComposer
    extends Composer<_$JournalDatabase, $JournalBlocksTable> {
  $$JournalBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JournalBlocksTableTableManager
    extends
        RootTableManager<
          _$JournalDatabase,
          $JournalBlocksTable,
          JournalBlockRow,
          $$JournalBlocksTableFilterComposer,
          $$JournalBlocksTableOrderingComposer,
          $$JournalBlocksTableAnnotationComposer,
          $$JournalBlocksTableCreateCompanionBuilder,
          $$JournalBlocksTableUpdateCompanionBuilder,
          (
            JournalBlockRow,
            BaseReferences<
              _$JournalDatabase,
              $JournalBlocksTable,
              JournalBlockRow
            >,
          ),
          JournalBlockRow,
          PrefetchHooks Function()
        > {
  $$JournalBlocksTableTableManager(
    _$JournalDatabase db,
    $JournalBlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalBlocksCompanion(
                id: id,
                pageId: pageId,
                type: type,
                orderIndex: orderIndex,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pageId,
                required String type,
                required int orderIndex,
                required String payload,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalBlocksCompanion.insert(
                id: id,
                pageId: pageId,
                type: type,
                orderIndex: orderIndex,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$JournalDatabase,
      $JournalBlocksTable,
      JournalBlockRow,
      $$JournalBlocksTableFilterComposer,
      $$JournalBlocksTableOrderingComposer,
      $$JournalBlocksTableAnnotationComposer,
      $$JournalBlocksTableCreateCompanionBuilder,
      $$JournalBlocksTableUpdateCompanionBuilder,
      (
        JournalBlockRow,
        BaseReferences<_$JournalDatabase, $JournalBlocksTable, JournalBlockRow>,
      ),
      JournalBlockRow,
      PrefetchHooks Function()
    >;

class $JournalDatabaseManager {
  final _$JournalDatabase _db;
  $JournalDatabaseManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db, _db.journals);
  $$JournalPagesTableTableManager get journalPages =>
      $$JournalPagesTableTableManager(_db, _db.journalPages);
  $$JournalBlocksTableTableManager get journalBlocks =>
      $$JournalBlocksTableTableManager(_db, _db.journalBlocks);
}
