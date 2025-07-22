import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Drift table for notes
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get notebookUuid => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isOffline => boolean().withDefault(const Constant(false))();
  TextColumn get localVersion => text().nullable()();
  TextColumn get serverVersion => text().nullable()();
  TextColumn get lastSyncAt => text().nullable()();
  TextColumn get tags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get color => text().nullable()();
  IntColumn get priority => integer().nullable()();
  TextColumn get notebookName => text().nullable()();
  IntColumn get noteCount => integer().nullable()();
}

/// Drift table for notebooks
class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isOffline => boolean().withDefault(const Constant(false))();
  TextColumn get localVersion => text().nullable()();
  TextColumn get serverVersion => text().nullable()();
  TextColumn get lastSyncAt => text().nullable()();
  IntColumn get noteCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().nullable()();
  TextColumn get noteIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

/// Konwerter listy stringów na JSON i z powrotem (dla tags/noteIds)
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(
      (fromDb.startsWith('[')
              ? (fromDb.length > 2
                  ? fromDb.substring(1, fromDb.length - 1).split(',')
                  : [])
              : fromDb.split(','))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty),
    );
  }

  @override
  String toSql(List<String> value) => '[${value.join(',')}]';
}

/// Drift database
@DriftDatabase(tables: [Notes, Notebooks])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
