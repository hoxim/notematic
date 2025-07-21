// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notebookUuidMeta =
      const VerificationMeta('notebookUuid');
  @override
  late final GeneratedColumn<String> notebookUuid = GeneratedColumn<String>(
      'notebook_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isOfflineMeta =
      const VerificationMeta('isOffline');
  @override
  late final GeneratedColumn<bool> isOffline = GeneratedColumn<bool>(
      'is_offline', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_offline" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localVersionMeta =
      const VerificationMeta('localVersion');
  @override
  late final GeneratedColumn<String> localVersion = GeneratedColumn<String>(
      'local_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverVersionMeta =
      const VerificationMeta('serverVersion');
  @override
  late final GeneratedColumn<String> serverVersion = GeneratedColumn<String>(
      'server_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($NotesTable.$convertertags);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notebookNameMeta =
      const VerificationMeta('notebookName');
  @override
  late final GeneratedColumn<String> notebookName = GeneratedColumn<String>(
      'notebook_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteCountMeta =
      const VerificationMeta('noteCount');
  @override
  late final GeneratedColumn<int> noteCount = GeneratedColumn<int>(
      'note_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        title,
        content,
        notebookUuid,
        createdAt,
        updatedAt,
        deleted,
        isDirty,
        isOffline,
        localVersion,
        serverVersion,
        lastSyncAt,
        tags,
        color,
        priority,
        notebookName,
        noteCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('notebook_uuid')) {
      context.handle(
          _notebookUuidMeta,
          notebookUuid.isAcceptableOrUnknown(
              data['notebook_uuid']!, _notebookUuidMeta));
    } else if (isInserting) {
      context.missing(_notebookUuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_offline')) {
      context.handle(_isOfflineMeta,
          isOffline.isAcceptableOrUnknown(data['is_offline']!, _isOfflineMeta));
    }
    if (data.containsKey('local_version')) {
      context.handle(
          _localVersionMeta,
          localVersion.isAcceptableOrUnknown(
              data['local_version']!, _localVersionMeta));
    }
    if (data.containsKey('server_version')) {
      context.handle(
          _serverVersionMeta,
          serverVersion.isAcceptableOrUnknown(
              data['server_version']!, _serverVersionMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('notebook_name')) {
      context.handle(
          _notebookNameMeta,
          notebookName.isAcceptableOrUnknown(
              data['notebook_name']!, _notebookNameMeta));
    }
    if (data.containsKey('note_count')) {
      context.handle(_noteCountMeta,
          noteCount.isAcceptableOrUnknown(data['note_count']!, _noteCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      notebookUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notebook_uuid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isOffline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_offline'])!,
      localVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_version']),
      serverVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_version']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_sync_at']),
      tags: $NotesTable.$convertertags.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority']),
      notebookName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notebook_name']),
      noteCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}note_count']),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final String notebookUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final bool isDirty;
  final bool isOffline;
  final String? localVersion;
  final String? serverVersion;
  final String? lastSyncAt;
  final List<String> tags;
  final String? color;
  final int? priority;
  final String? notebookName;
  final int? noteCount;
  const Note(
      {required this.id,
      required this.uuid,
      required this.title,
      required this.content,
      required this.notebookUuid,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      required this.isDirty,
      required this.isOffline,
      this.localVersion,
      this.serverVersion,
      this.lastSyncAt,
      required this.tags,
      this.color,
      this.priority,
      this.notebookName,
      this.noteCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['notebook_uuid'] = Variable<String>(notebookUuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_offline'] = Variable<bool>(isOffline);
    if (!nullToAbsent || localVersion != null) {
      map['local_version'] = Variable<String>(localVersion);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<String>(serverVersion);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<String>(lastSyncAt);
    }
    {
      map['tags'] = Variable<String>($NotesTable.$convertertags.toSql(tags));
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || notebookName != null) {
      map['notebook_name'] = Variable<String>(notebookName);
    }
    if (!nullToAbsent || noteCount != null) {
      map['note_count'] = Variable<int>(noteCount);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      content: Value(content),
      notebookUuid: Value(notebookUuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      isOffline: Value(isOffline),
      localVersion: localVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(localVersion),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      tags: Value(tags),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      notebookName: notebookName == null && nullToAbsent
          ? const Value.absent()
          : Value(notebookName),
      noteCount: noteCount == null && nullToAbsent
          ? const Value.absent()
          : Value(noteCount),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      notebookUuid: serializer.fromJson<String>(json['notebookUuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isOffline: serializer.fromJson<bool>(json['isOffline']),
      localVersion: serializer.fromJson<String?>(json['localVersion']),
      serverVersion: serializer.fromJson<String?>(json['serverVersion']),
      lastSyncAt: serializer.fromJson<String?>(json['lastSyncAt']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      color: serializer.fromJson<String?>(json['color']),
      priority: serializer.fromJson<int?>(json['priority']),
      notebookName: serializer.fromJson<String?>(json['notebookName']),
      noteCount: serializer.fromJson<int?>(json['noteCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'notebookUuid': serializer.toJson<String>(notebookUuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isOffline': serializer.toJson<bool>(isOffline),
      'localVersion': serializer.toJson<String?>(localVersion),
      'serverVersion': serializer.toJson<String?>(serverVersion),
      'lastSyncAt': serializer.toJson<String?>(lastSyncAt),
      'tags': serializer.toJson<List<String>>(tags),
      'color': serializer.toJson<String?>(color),
      'priority': serializer.toJson<int?>(priority),
      'notebookName': serializer.toJson<String?>(notebookName),
      'noteCount': serializer.toJson<int?>(noteCount),
    };
  }

  Note copyWith(
          {int? id,
          String? uuid,
          String? title,
          String? content,
          String? notebookUuid,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          bool? isDirty,
          bool? isOffline,
          Value<String?> localVersion = const Value.absent(),
          Value<String?> serverVersion = const Value.absent(),
          Value<String?> lastSyncAt = const Value.absent(),
          List<String>? tags,
          Value<String?> color = const Value.absent(),
          Value<int?> priority = const Value.absent(),
          Value<String?> notebookName = const Value.absent(),
          Value<int?> noteCount = const Value.absent()}) =>
      Note(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        title: title ?? this.title,
        content: content ?? this.content,
        notebookUuid: notebookUuid ?? this.notebookUuid,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        isDirty: isDirty ?? this.isDirty,
        isOffline: isOffline ?? this.isOffline,
        localVersion:
            localVersion.present ? localVersion.value : this.localVersion,
        serverVersion:
            serverVersion.present ? serverVersion.value : this.serverVersion,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        tags: tags ?? this.tags,
        color: color.present ? color.value : this.color,
        priority: priority.present ? priority.value : this.priority,
        notebookName:
            notebookName.present ? notebookName.value : this.notebookName,
        noteCount: noteCount.present ? noteCount.value : this.noteCount,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      notebookUuid: data.notebookUuid.present
          ? data.notebookUuid.value
          : this.notebookUuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isOffline: data.isOffline.present ? data.isOffline.value : this.isOffline,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      tags: data.tags.present ? data.tags.value : this.tags,
      color: data.color.present ? data.color.value : this.color,
      priority: data.priority.present ? data.priority.value : this.priority,
      notebookName: data.notebookName.present
          ? data.notebookName.value
          : this.notebookName,
      noteCount: data.noteCount.present ? data.noteCount.value : this.noteCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('notebookUuid: $notebookUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('isOffline: $isOffline, ')
          ..write('localVersion: $localVersion, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('tags: $tags, ')
          ..write('color: $color, ')
          ..write('priority: $priority, ')
          ..write('notebookName: $notebookName, ')
          ..write('noteCount: $noteCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      title,
      content,
      notebookUuid,
      createdAt,
      updatedAt,
      deleted,
      isDirty,
      isOffline,
      localVersion,
      serverVersion,
      lastSyncAt,
      tags,
      color,
      priority,
      notebookName,
      noteCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.content == this.content &&
          other.notebookUuid == this.notebookUuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.isOffline == this.isOffline &&
          other.localVersion == this.localVersion &&
          other.serverVersion == this.serverVersion &&
          other.lastSyncAt == this.lastSyncAt &&
          other.tags == this.tags &&
          other.color == this.color &&
          other.priority == this.priority &&
          other.notebookName == this.notebookName &&
          other.noteCount == this.noteCount);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> content;
  final Value<String> notebookUuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<bool> isOffline;
  final Value<String?> localVersion;
  final Value<String?> serverVersion;
  final Value<String?> lastSyncAt;
  final Value<List<String>> tags;
  final Value<String?> color;
  final Value<int?> priority;
  final Value<String?> notebookName;
  final Value<int?> noteCount;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.notebookUuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.color = const Value.absent(),
    this.priority = const Value.absent(),
    this.notebookName = const Value.absent(),
    this.noteCount = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    required String content,
    required String notebookUuid,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.color = const Value.absent(),
    this.priority = const Value.absent(),
    this.notebookName = const Value.absent(),
    this.noteCount = const Value.absent(),
  })  : uuid = Value(uuid),
        title = Value(title),
        content = Value(content),
        notebookUuid = Value(notebookUuid),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? notebookUuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<bool>? isOffline,
    Expression<String>? localVersion,
    Expression<String>? serverVersion,
    Expression<String>? lastSyncAt,
    Expression<String>? tags,
    Expression<String>? color,
    Expression<int>? priority,
    Expression<String>? notebookName,
    Expression<int>? noteCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (notebookUuid != null) 'notebook_uuid': notebookUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isOffline != null) 'is_offline': isOffline,
      if (localVersion != null) 'local_version': localVersion,
      if (serverVersion != null) 'server_version': serverVersion,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (tags != null) 'tags': tags,
      if (color != null) 'color': color,
      if (priority != null) 'priority': priority,
      if (notebookName != null) 'notebook_name': notebookName,
      if (noteCount != null) 'note_count': noteCount,
    });
  }

  NotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? title,
      Value<String>? content,
      Value<String>? notebookUuid,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<bool>? isDirty,
      Value<bool>? isOffline,
      Value<String?>? localVersion,
      Value<String?>? serverVersion,
      Value<String?>? lastSyncAt,
      Value<List<String>>? tags,
      Value<String?>? color,
      Value<int?>? priority,
      Value<String?>? notebookName,
      Value<int?>? noteCount}) {
    return NotesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      notebookUuid: notebookUuid ?? this.notebookUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      isOffline: isOffline ?? this.isOffline,
      localVersion: localVersion ?? this.localVersion,
      serverVersion: serverVersion ?? this.serverVersion,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      notebookName: notebookName ?? this.notebookName,
      noteCount: noteCount ?? this.noteCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (notebookUuid.present) {
      map['notebook_uuid'] = Variable<String>(notebookUuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isOffline.present) {
      map['is_offline'] = Variable<bool>(isOffline.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<String>(localVersion.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<String>(serverVersion.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($NotesTable.$convertertags.toSql(tags.value));
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (notebookName.present) {
      map['notebook_name'] = Variable<String>(notebookName.value);
    }
    if (noteCount.present) {
      map['note_count'] = Variable<int>(noteCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('notebookUuid: $notebookUuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('isOffline: $isOffline, ')
          ..write('localVersion: $localVersion, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('tags: $tags, ')
          ..write('color: $color, ')
          ..write('priority: $priority, ')
          ..write('notebookName: $notebookName, ')
          ..write('noteCount: $noteCount')
          ..write(')'))
        .toString();
  }
}

class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isOfflineMeta =
      const VerificationMeta('isOffline');
  @override
  late final GeneratedColumn<bool> isOffline = GeneratedColumn<bool>(
      'is_offline', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_offline" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localVersionMeta =
      const VerificationMeta('localVersion');
  @override
  late final GeneratedColumn<String> localVersion = GeneratedColumn<String>(
      'local_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverVersionMeta =
      const VerificationMeta('serverVersion');
  @override
  late final GeneratedColumn<String> serverVersion = GeneratedColumn<String>(
      'server_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteCountMeta =
      const VerificationMeta('noteCount');
  @override
  late final GeneratedColumn<int> noteCount = GeneratedColumn<int>(
      'note_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> noteIds =
      GeneratedColumn<String>('note_ids', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<String>>($NotebooksTable.$converternoteIds);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        name,
        description,
        color,
        createdAt,
        updatedAt,
        deleted,
        isDirty,
        isOffline,
        localVersion,
        serverVersion,
        lastSyncAt,
        noteCount,
        isDefault,
        sortOrder,
        noteIds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(Insertable<Notebook> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('is_offline')) {
      context.handle(_isOfflineMeta,
          isOffline.isAcceptableOrUnknown(data['is_offline']!, _isOfflineMeta));
    }
    if (data.containsKey('local_version')) {
      context.handle(
          _localVersionMeta,
          localVersion.isAcceptableOrUnknown(
              data['local_version']!, _localVersionMeta));
    }
    if (data.containsKey('server_version')) {
      context.handle(
          _serverVersionMeta,
          serverVersion.isAcceptableOrUnknown(
              data['server_version']!, _serverVersionMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('note_count')) {
      context.handle(_noteCountMeta,
          noteCount.isAcceptableOrUnknown(data['note_count']!, _noteCountMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      isOffline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_offline'])!,
      localVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_version']),
      serverVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_version']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_sync_at']),
      noteCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}note_count'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order']),
      noteIds: $NotebooksTable.$converternoteIds.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_ids'])!),
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converternoteIds =
      const StringListConverter();
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final int id;
  final String uuid;
  final String name;
  final String? description;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;
  final bool isDirty;
  final bool isOffline;
  final String? localVersion;
  final String? serverVersion;
  final String? lastSyncAt;
  final int noteCount;
  final bool isDefault;
  final int? sortOrder;
  final List<String> noteIds;
  const Notebook(
      {required this.id,
      required this.uuid,
      required this.name,
      this.description,
      this.color,
      required this.createdAt,
      required this.updatedAt,
      required this.deleted,
      required this.isDirty,
      required this.isOffline,
      this.localVersion,
      this.serverVersion,
      this.lastSyncAt,
      required this.noteCount,
      required this.isDefault,
      this.sortOrder,
      required this.noteIds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['is_offline'] = Variable<bool>(isOffline);
    if (!nullToAbsent || localVersion != null) {
      map['local_version'] = Variable<String>(localVersion);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<String>(serverVersion);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<String>(lastSyncAt);
    }
    map['note_count'] = Variable<int>(noteCount);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    {
      map['note_ids'] =
          Variable<String>($NotebooksTable.$converternoteIds.toSql(noteIds));
    }
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      isDirty: Value(isDirty),
      isOffline: Value(isOffline),
      localVersion: localVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(localVersion),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      noteCount: Value(noteCount),
      isDefault: Value(isDefault),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
      noteIds: Value(noteIds),
    );
  }

  factory Notebook.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      isOffline: serializer.fromJson<bool>(json['isOffline']),
      localVersion: serializer.fromJson<String?>(json['localVersion']),
      serverVersion: serializer.fromJson<String?>(json['serverVersion']),
      lastSyncAt: serializer.fromJson<String?>(json['lastSyncAt']),
      noteCount: serializer.fromJson<int>(json['noteCount']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
      noteIds: serializer.fromJson<List<String>>(json['noteIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'isDirty': serializer.toJson<bool>(isDirty),
      'isOffline': serializer.toJson<bool>(isOffline),
      'localVersion': serializer.toJson<String?>(localVersion),
      'serverVersion': serializer.toJson<String?>(serverVersion),
      'lastSyncAt': serializer.toJson<String?>(lastSyncAt),
      'noteCount': serializer.toJson<int>(noteCount),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int?>(sortOrder),
      'noteIds': serializer.toJson<List<String>>(noteIds),
    };
  }

  Notebook copyWith(
          {int? id,
          String? uuid,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> color = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? deleted,
          bool? isDirty,
          bool? isOffline,
          Value<String?> localVersion = const Value.absent(),
          Value<String?> serverVersion = const Value.absent(),
          Value<String?> lastSyncAt = const Value.absent(),
          int? noteCount,
          bool? isDefault,
          Value<int?> sortOrder = const Value.absent(),
          List<String>? noteIds}) =>
      Notebook(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        color: color.present ? color.value : this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deleted: deleted ?? this.deleted,
        isDirty: isDirty ?? this.isDirty,
        isOffline: isOffline ?? this.isOffline,
        localVersion:
            localVersion.present ? localVersion.value : this.localVersion,
        serverVersion:
            serverVersion.present ? serverVersion.value : this.serverVersion,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        noteCount: noteCount ?? this.noteCount,
        isDefault: isDefault ?? this.isDefault,
        sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
        noteIds: noteIds ?? this.noteIds,
      );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      isOffline: data.isOffline.present ? data.isOffline.value : this.isOffline,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      noteCount: data.noteCount.present ? data.noteCount.value : this.noteCount,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      noteIds: data.noteIds.present ? data.noteIds.value : this.noteIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('isOffline: $isOffline, ')
          ..write('localVersion: $localVersion, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('noteCount: $noteCount, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('noteIds: $noteIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      name,
      description,
      color,
      createdAt,
      updatedAt,
      deleted,
      isDirty,
      isOffline,
      localVersion,
      serverVersion,
      lastSyncAt,
      noteCount,
      isDefault,
      sortOrder,
      noteIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.isDirty == this.isDirty &&
          other.isOffline == this.isOffline &&
          other.localVersion == this.localVersion &&
          other.serverVersion == this.serverVersion &&
          other.lastSyncAt == this.lastSyncAt &&
          other.noteCount == this.noteCount &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder &&
          other.noteIds == this.noteIds);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<bool> isDirty;
  final Value<bool> isOffline;
  final Value<String?> localVersion;
  final Value<String?> serverVersion;
  final Value<String?> lastSyncAt;
  final Value<int> noteCount;
  final Value<bool> isDefault;
  final Value<int?> sortOrder;
  final Value<List<String>> noteIds;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.noteCount = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.noteIds = const Value.absent(),
  });
  NotebooksCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.noteCount = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.noteIds = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Notebook> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<bool>? isDirty,
    Expression<bool>? isOffline,
    Expression<String>? localVersion,
    Expression<String>? serverVersion,
    Expression<String>? lastSyncAt,
    Expression<int>? noteCount,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<String>? noteIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (isDirty != null) 'is_dirty': isDirty,
      if (isOffline != null) 'is_offline': isOffline,
      if (localVersion != null) 'local_version': localVersion,
      if (serverVersion != null) 'server_version': serverVersion,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (noteCount != null) 'note_count': noteCount,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (noteIds != null) 'note_ids': noteIds,
    });
  }

  NotebooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? deleted,
      Value<bool>? isDirty,
      Value<bool>? isOffline,
      Value<String?>? localVersion,
      Value<String?>? serverVersion,
      Value<String?>? lastSyncAt,
      Value<int>? noteCount,
      Value<bool>? isDefault,
      Value<int?>? sortOrder,
      Value<List<String>>? noteIds}) {
    return NotebooksCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      isDirty: isDirty ?? this.isDirty,
      isOffline: isOffline ?? this.isOffline,
      localVersion: localVersion ?? this.localVersion,
      serverVersion: serverVersion ?? this.serverVersion,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      noteCount: noteCount ?? this.noteCount,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      noteIds: noteIds ?? this.noteIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (isOffline.present) {
      map['is_offline'] = Variable<bool>(isOffline.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<String>(localVersion.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<String>(serverVersion.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (noteCount.present) {
      map['note_count'] = Variable<int>(noteCount.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (noteIds.present) {
      map['note_ids'] = Variable<String>(
          $NotebooksTable.$converternoteIds.toSql(noteIds.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('isDirty: $isDirty, ')
          ..write('isOffline: $isOffline, ')
          ..write('localVersion: $localVersion, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('noteCount: $noteCount, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('noteIds: $noteIds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [notes, notebooks];
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  required String uuid,
  required String title,
  required String content,
  required String notebookUuid,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<bool> isOffline,
  Value<String?> localVersion,
  Value<String?> serverVersion,
  Value<String?> lastSyncAt,
  Value<List<String>> tags,
  Value<String?> color,
  Value<int?> priority,
  Value<String?> notebookName,
  Value<int?> noteCount,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> title,
  Value<String> content,
  Value<String> notebookUuid,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<bool> isOffline,
  Value<String?> localVersion,
  Value<String?> serverVersion,
  Value<String?> lastSyncAt,
  Value<List<String>> tags,
  Value<String?> color,
  Value<int?> priority,
  Value<String?> notebookName,
  Value<int?> noteCount,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notebookUuid => $composableBuilder(
      column: $table.notebookUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localVersion => $composableBuilder(
      column: $table.localVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notebookName => $composableBuilder(
      column: $table.notebookName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get noteCount => $composableBuilder(
      column: $table.noteCount, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notebookUuid => $composableBuilder(
      column: $table.notebookUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localVersion => $composableBuilder(
      column: $table.localVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notebookName => $composableBuilder(
      column: $table.notebookName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get noteCount => $composableBuilder(
      column: $table.noteCount, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get notebookUuid => $composableBuilder(
      column: $table.notebookUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isOffline =>
      $composableBuilder(column: $table.isOffline, builder: (column) => column);

  GeneratedColumn<String> get localVersion => $composableBuilder(
      column: $table.localVersion, builder: (column) => column);

  GeneratedColumn<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => column);

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get notebookName => $composableBuilder(
      column: $table.notebookName, builder: (column) => column);

  GeneratedColumn<int> get noteCount =>
      $composableBuilder(column: $table.noteCount, builder: (column) => column);
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> notebookUuid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isOffline = const Value.absent(),
            Value<String?> localVersion = const Value.absent(),
            Value<String?> serverVersion = const Value.absent(),
            Value<String?> lastSyncAt = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            Value<String?> notebookName = const Value.absent(),
            Value<int?> noteCount = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            uuid: uuid,
            title: title,
            content: content,
            notebookUuid: notebookUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            isDirty: isDirty,
            isOffline: isOffline,
            localVersion: localVersion,
            serverVersion: serverVersion,
            lastSyncAt: lastSyncAt,
            tags: tags,
            color: color,
            priority: priority,
            notebookName: notebookName,
            noteCount: noteCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String title,
            required String content,
            required String notebookUuid,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isOffline = const Value.absent(),
            Value<String?> localVersion = const Value.absent(),
            Value<String?> serverVersion = const Value.absent(),
            Value<String?> lastSyncAt = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int?> priority = const Value.absent(),
            Value<String?> notebookName = const Value.absent(),
            Value<int?> noteCount = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            uuid: uuid,
            title: title,
            content: content,
            notebookUuid: notebookUuid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            isDirty: isDirty,
            isOffline: isOffline,
            localVersion: localVersion,
            serverVersion: serverVersion,
            lastSyncAt: lastSyncAt,
            tags: tags,
            color: color,
            priority: priority,
            notebookName: notebookName,
            noteCount: noteCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()>;
typedef $$NotebooksTableCreateCompanionBuilder = NotebooksCompanion Function({
  Value<int> id,
  required String uuid,
  required String name,
  Value<String?> description,
  Value<String?> color,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<bool> isOffline,
  Value<String?> localVersion,
  Value<String?> serverVersion,
  Value<String?> lastSyncAt,
  Value<int> noteCount,
  Value<bool> isDefault,
  Value<int?> sortOrder,
  Value<List<String>> noteIds,
});
typedef $$NotebooksTableUpdateCompanionBuilder = NotebooksCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> name,
  Value<String?> description,
  Value<String?> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
  Value<bool> isDirty,
  Value<bool> isOffline,
  Value<String?> localVersion,
  Value<String?> serverVersion,
  Value<String?> lastSyncAt,
  Value<int> noteCount,
  Value<bool> isDefault,
  Value<int?> sortOrder,
  Value<List<String>> noteIds,
});

class $$NotebooksTableFilterComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localVersion => $composableBuilder(
      column: $table.localVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get noteCount => $composableBuilder(
      column: $table.noteCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get noteIds => $composableBuilder(
          column: $table.noteIds,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localVersion => $composableBuilder(
      column: $table.localVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get noteCount => $composableBuilder(
      column: $table.noteCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noteIds => $composableBuilder(
      column: $table.noteIds, builder: (column) => ColumnOrderings(column));
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<bool> get isOffline =>
      $composableBuilder(column: $table.isOffline, builder: (column) => column);

  GeneratedColumn<String> get localVersion => $composableBuilder(
      column: $table.localVersion, builder: (column) => column);

  GeneratedColumn<String> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => column);

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<int> get noteCount =>
      $composableBuilder(column: $table.noteCount, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get noteIds =>
      $composableBuilder(column: $table.noteIds, builder: (column) => column);
}

class $$NotebooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotebooksTable,
    Notebook,
    $$NotebooksTableFilterComposer,
    $$NotebooksTableOrderingComposer,
    $$NotebooksTableAnnotationComposer,
    $$NotebooksTableCreateCompanionBuilder,
    $$NotebooksTableUpdateCompanionBuilder,
    (Notebook, BaseReferences<_$AppDatabase, $NotebooksTable, Notebook>),
    Notebook,
    PrefetchHooks Function()> {
  $$NotebooksTableTableManager(_$AppDatabase db, $NotebooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isOffline = const Value.absent(),
            Value<String?> localVersion = const Value.absent(),
            Value<String?> serverVersion = const Value.absent(),
            Value<String?> lastSyncAt = const Value.absent(),
            Value<int> noteCount = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<int?> sortOrder = const Value.absent(),
            Value<List<String>> noteIds = const Value.absent(),
          }) =>
              NotebooksCompanion(
            id: id,
            uuid: uuid,
            name: name,
            description: description,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            isDirty: isDirty,
            isOffline: isOffline,
            localVersion: localVersion,
            serverVersion: serverVersion,
            lastSyncAt: lastSyncAt,
            noteCount: noteCount,
            isDefault: isDefault,
            sortOrder: sortOrder,
            noteIds: noteIds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> color = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> deleted = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<bool> isOffline = const Value.absent(),
            Value<String?> localVersion = const Value.absent(),
            Value<String?> serverVersion = const Value.absent(),
            Value<String?> lastSyncAt = const Value.absent(),
            Value<int> noteCount = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<int?> sortOrder = const Value.absent(),
            Value<List<String>> noteIds = const Value.absent(),
          }) =>
              NotebooksCompanion.insert(
            id: id,
            uuid: uuid,
            name: name,
            description: description,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deleted: deleted,
            isDirty: isDirty,
            isOffline: isOffline,
            localVersion: localVersion,
            serverVersion: serverVersion,
            lastSyncAt: lastSyncAt,
            noteCount: noteCount,
            isDefault: isDefault,
            sortOrder: sortOrder,
            noteIds: noteIds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotebooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotebooksTable,
    Notebook,
    $$NotebooksTableFilterComposer,
    $$NotebooksTableOrderingComposer,
    $$NotebooksTableAnnotationComposer,
    $$NotebooksTableCreateCompanionBuilder,
    $$NotebooksTableUpdateCompanionBuilder,
    (Notebook, BaseReferences<_$AppDatabase, $NotebooksTable, Notebook>),
    Notebook,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
}
