import '../database/shared_db_executor.dart';
import '../database/app_database.dart';
import '../models/unified_note.dart';
import '../models/unified_notebook.dart';
import 'logger_service.dart';
import 'package:drift/drift.dart' show Value;

/// Unified storage service using Drift for local database
class UnifiedStorageService {
  static AppDatabase? _db;
  static final UnifiedStorageService _instance =
      UnifiedStorageService._internal();
  final LoggerService _logger = LoggerService();
  UnifiedStorageService._internal();
  factory UnifiedStorageService() => _instance;

  /// Initialize the storage service (only once)
  Future<void> initialize() async {
    if (_db != null) return;
    try {
      final executor = await createDbExecutor();
      _db = AppDatabase(executor);
      _logger.info('UnifiedStorageService initialized (Drift)');
    } catch (e) {
      _logger.error('Failed to initialize UnifiedStorageService: $e');
      rethrow;
    }
  }

  AppDatabase get db {
    if (_db == null) {
      throw StateError(
          'UnifiedStorageService not initialized. Call initialize() first.');
    }
    return _db!;
  }

  /// Close the store
  Future<void> close() async {
    try {
      await _db!.close();
      _logger.info('UnifiedStorageService closed');
    } catch (e) {
      _logger.error('Failed to close UnifiedStorageService: $e');
    }
  }

  // ===== NOTE OPERATIONS =====

  /// Create a new note
  Future<UnifiedNote> createNote({
    required String title,
    required String content,
    required String notebookUuid,
    List<String> tags = const [],
    String? color,
    int? priority,
  }) async {
    try {
      // Pobierz nazwę notebooka
      final notebook = await getNotebookByUuid(notebookUuid);
      final notebookName = notebook?.name ?? '';
      final note = UnifiedNote.create(
        title: title,
        content: content,
        notebookUuid: notebookUuid,
        tags: tags,
        color: color,
        priority: priority,
        notebookName: notebookName,
      );
      await _saveNote(note);
      _logger.info('Created note:  [1m${note.title} [0m');
      return note;
    } catch (e) {
      _logger.error('Failed to create note: $e');
      rethrow;
    }
  }

  /// Get all notes
  Future<List<UnifiedNote>> getAllNotes() async {
    try {
      final rows = await _db!.select(_db!.notes).get();
      return rows.map<UnifiedNote>(_noteFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get all notes: $e');
      return [];
    }
  }

  /// Get notes by notebook
  Future<List<UnifiedNote>> getNotesByNotebook(String notebookUuid) async {
    try {
      final rows = await (_db!.select(_db!.notes)
            ..where((tbl) => tbl.notebookUuid.equals(notebookUuid)))
          .get();
      return rows.map<UnifiedNote>(_noteFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get notes by notebook: $e');
      return [];
    }
  }

  /// Get note by UUID
  Future<UnifiedNote?> getNoteByUuid(String uuid) async {
    try {
      final rows = await (_db!.select(_db!.notes)
            ..where((tbl) => tbl.uuid.equals(uuid)))
          .get();
      return rows.isNotEmpty ? _noteFromRow(rows.first) : null;
    } catch (e) {
      _logger.error('Failed to get note by UUID: $e');
      return null;
    }
  }

  /// Update note
  Future<void> updateNote(UnifiedNote note) async {
    try {
      final oldNotebookName = note.notebookName;
      final oldNotebookUuid = note.notebookUuid;
      // Jeśli notebookUuid się zmienił, pobierz nową nazwę notebooka
      final notebook = await getNotebookByUuid(note.notebookUuid);
      note.notebookName = notebook?.name ?? note.notebookName;
      _logger.info(
          '[updateNote] uuid=${note.uuid}, oldNotebookUuid=$oldNotebookUuid, newNotebookUuid=${note.notebookUuid}, oldNotebookName=$oldNotebookName, newNotebookName=${note.notebookName}');
      note.markAsDirty();
      await _saveNote(note);
      _logger.info('Updated note: ${note.title}');
    } catch (e) {
      _logger.error('Failed to update note: $e');
      rethrow;
    }
  }

  /// Delete note (soft delete)
  Future<void> deleteNote(String uuid) async {
    try {
      _logger.info('Attempting to delete note with uuid: $uuid');
      final note = await getNoteByUuid(uuid);
      if (note != null) {
        _logger.info(
            'Note found for deletion: title="${note.title}", uuid=$uuid, deleted=${note.deleted}');
        note.delete();
        await _saveNote(note);
        _logger.info(
            'Deleted note: ${note.title} (uuid: $uuid, deleted flag: ${note.deleted})');
      } else {
        _logger.warning('Note to delete not found: uuid=$uuid');
      }
    } catch (e) {
      _logger.error('Failed to delete note: $e');
      rethrow;
    }
  }

  /// Get notes that need sync
  Future<List<UnifiedNote>> getDirtyNotes() async {
    try {
      final rows = await (_db!.select(_db!.notes)
            ..where((tbl) => tbl.isDirty.equals(true)))
          .get();
      return rows.map<UnifiedNote>(_noteFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get dirty notes: $e');
      return [];
    }
  }

  /// Get offline notes
  Future<List<UnifiedNote>> getOfflineNotes() async {
    try {
      final rows = await (_db!.select(_db!.notes)
            ..where((tbl) => tbl.isOffline.equals(true)))
          .get();
      return rows.map<UnifiedNote>(_noteFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get offline notes: $e');
      return [];
    }
  }

  /// Get notes by tags
  Future<List<UnifiedNote>> getNotesByTags(List<String> tags) async {
    try {
      final allNotes = await getAllNotes();
      return allNotes
          .where((note) => note.tags.any((tag) => tags.contains(tag)))
          .toList();
    } catch (e) {
      _logger.error('Failed to get notes by tags: $e');
      return [];
    }
  }

  // ===== NOTEBOOK OPERATIONS =====

  /// Create a new notebook
  Future<UnifiedNotebook> createNotebook({
    required String name,
    String? description,
    String? color,
    bool isDefault = false,
    int? sortOrder,
  }) async {
    try {
      final notebook = UnifiedNotebook.create(
        name: name,
        description: description,
        color: color,
        isDefault: isDefault,
        sortOrder: sortOrder,
      );
      await _saveNotebook(notebook);
      _logger.info('Created notebook: ${notebook.name}');
      return notebook;
    } catch (e) {
      _logger.error('Failed to create notebook: $e');
      rethrow;
    }
  }

  /// Get all notebooks
  Future<List<UnifiedNotebook>> getAllNotebooks() async {
    try {
      final rows = await _db!.select(_db!.notebooks).get();
      return rows.map<UnifiedNotebook>(_notebookFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get all notebooks: $e');
      return [];
    }
  }

  /// Get notebook by UUID
  Future<UnifiedNotebook?> getNotebookByUuid(String uuid) async {
    try {
      final rows = await (_db!.select(_db!.notebooks)
            ..where((tbl) => tbl.uuid.equals(uuid)))
          .get();
      return rows.isNotEmpty ? _notebookFromRow(rows.first) : null;
    } catch (e) {
      _logger.error('Failed to get notebook by UUID: $e');
      return null;
    }
  }

  /// Get default notebook
  Future<UnifiedNotebook?> getDefaultNotebook() async {
    try {
      final rows = await (_db!.select(_db!.notebooks)
            ..where((tbl) => tbl.isDefault.equals(true)))
          .get();
      return rows.isNotEmpty ? _notebookFromRow(rows.first) : null;
    } catch (e) {
      _logger.error('Failed to get default notebook: $e');
      return null;
    }
  }

  /// Update notebook
  Future<void> updateNotebook(UnifiedNotebook notebook) async {
    try {
      notebook.markAsDirty();
      await _saveNotebook(notebook);
      _logger.info('Updated notebook: ${notebook.name}');
    } catch (e) {
      _logger.error('Failed to update notebook: $e');
      rethrow;
    }
  }

  /// Delete notebook (soft delete)
  Future<void> deleteNotebook(String uuid) async {
    try {
      final notebook = await getNotebookByUuid(uuid);
      if (notebook != null) {
        notebook.delete();
        await _saveNotebook(notebook);
        _logger.info('Deleted notebook: ${notebook.name}');
      }
    } catch (e) {
      _logger.error('Failed to delete notebook: $e');
      rethrow;
    }
  }

  /// Get notebooks that need sync
  Future<List<UnifiedNotebook>> getDirtyNotebooks() async {
    try {
      final rows = await (_db!.select(_db!.notebooks)
            ..where((tbl) => tbl.isDirty.equals(true)))
          .get();
      return rows.map<UnifiedNotebook>(_notebookFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get dirty notebooks: $e');
      return [];
    }
  }

  /// Get offline notebooks
  Future<List<UnifiedNotebook>> getOfflineNotebooks() async {
    try {
      final rows = await (_db!.select(_db!.notebooks)
            ..where((tbl) => tbl.isOffline.equals(true)))
          .get();
      return rows.map<UnifiedNotebook>(_notebookFromRow).toList();
    } catch (e) {
      _logger.error('Failed to get offline notebooks: $e');
      return [];
    }
  }

  // ===== SYNC OPERATIONS =====

  /// Sync notes from API to local
  Future<void> syncNotesFromApi(List<Map<String, dynamic>> apiNotes) async {
    try {
      for (final apiNote in apiNotes) {
        final note = UnifiedNote.fromApi(apiNote);
        await _saveNote(note);
      }
      _logger.info('Synced ${apiNotes.length} notes from API');
    } catch (e) {
      _logger.error('Failed to sync notes from API: $e');
      rethrow;
    }
  }

  /// Sync notebooks from API to local
  Future<void> syncNotebooksFromApi(
      List<Map<String, dynamic>> apiNotebooks) async {
    try {
      for (final apiNotebook in apiNotebooks) {
        final notebook = UnifiedNotebook.fromApi(apiNotebook);
        await _saveNotebook(notebook);
      }
      _logger.info('Synced ${apiNotebooks.length} notebooks from API');
    } catch (e) {
      _logger.error('Failed to sync notebooks from API: $e');
      rethrow;
    }
  }

  /// Mark note as synced
  Future<void> markNoteAsSynced(String uuid, String serverVersion) async {
    try {
      final note = await getNoteByUuid(uuid);
      if (note != null) {
        note.markAsSynced(serverVersion);
        await _saveNote(note);
        _logger.info('Marked note as synced: ${note.title}');
      }
    } catch (e) {
      _logger.error('Failed to mark note as synced: $e');
      rethrow;
    }
  }

  /// Mark notebook as synced
  Future<void> markNotebookAsSynced(String uuid, String serverVersion) async {
    try {
      final notebook = await getNotebookByUuid(uuid);
      if (notebook != null) {
        notebook.markAsSynced(serverVersion);
        await _saveNotebook(notebook);
        _logger.info('Marked notebook as synced: ${notebook.name}');
      }
    } catch (e) {
      _logger.error('Failed to mark notebook as synced: $e');
      rethrow;
    }
  }

  // ===== UTILITY OPERATIONS =====

  /// Get all data for sync
  Future<Map<String, dynamic>> getAllData() async {
    try {
      final notes = await getAllNotes();
      final notebooks = await getAllNotebooks();
      return {
        'notes': notes.map((note) => note.toMap()).toList(),
        'notebooks': notebooks.map((notebook) => notebook.toMap()).toList(),
      };
    } catch (e) {
      _logger.error('Failed to get all data: $e');
      return {'notes': [], 'notebooks': []};
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _db!.delete(_db!.notes).go();
      await _db!.delete(_db!.notebooks).go();
      _logger.info('Cleared all data');
    } catch (e) {
      _logger.error('Failed to clear all data: $e');
      rethrow;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final allNotes = await getAllNotes();
      final allNotebooks = await getAllNotebooks();
      final dirtyNotes = await getDirtyNotes();
      final dirtyNotebooks = await getDirtyNotebooks();
      return {
        'totalNotes': allNotes.length,
        'totalNotebooks': allNotebooks.length,
        'dirtyNotes': dirtyNotes.length,
        'dirtyNotebooks': dirtyNotebooks.length,
        'syncedNotes': allNotes.where((note) => note.isSynced).length,
        'syncedNotebooks':
            allNotebooks.where((notebook) => notebook.isSynced).length,
        'offlineNotes': allNotes.where((note) => note.isOffline).length,
        'offlineNotebooks':
            allNotebooks.where((notebook) => notebook.isOffline).length,
      };
    } catch (e) {
      _logger.error('Failed to get sync stats: $e');
      return {};
    }
  }

  // ===== PRIVATE METHODS =====

  /// Save note to storage (insert or update)
  Future<void> _saveNote(UnifiedNote note) async {
    try {
      final existing = await getNoteByUuid(note.uuid);
      final companion = NotesCompanion(
        uuid: Value(note.uuid),
        title: Value(note.title),
        content: Value(note.content),
        notebookUuid: Value(note.notebookUuid),
        createdAt: Value(note.createdAt),
        updatedAt: Value(note.updatedAt),
        deleted: Value(note.deleted),
        isDirty: Value(note.isDirty),
        isOffline: Value(note.isOffline),
        localVersion: Value(note.localVersion),
        serverVersion: Value(note.serverVersion),
        lastSyncAt: Value(note.lastSyncAt),
        tags: Value(note.tags),
        color: Value(note.color),
        priority: Value(note.priority),
        notebookName: Value(note.notebookName),
        noteCount: Value(note.noteCount),
      );
      if (existing == null) {
        await _db!.into(_db!.notes).insert(companion);
      } else {
        await (_db!.update(_db!.notes)
              ..where((tbl) => tbl.uuid.equals(note.uuid)))
            .write(companion);
      }
      _logger.debug('Saved note: ${note.title}');
    } catch (e) {
      _logger.error('Failed to save note: $e');
      rethrow;
    }
  }

  /// Save notebook to storage (insert or update)
  Future<void> _saveNotebook(UnifiedNotebook notebook) async {
    try {
      final existing = await getNotebookByUuid(notebook.uuid);
      final companion = NotebooksCompanion(
        uuid: Value(notebook.uuid),
        name: Value(notebook.name),
        description: Value(notebook.description),
        color: Value(notebook.color),
        createdAt: Value(notebook.createdAt),
        updatedAt: Value(notebook.updatedAt),
        deleted: Value(notebook.deleted),
        isDirty: Value(notebook.isDirty),
        isOffline: Value(notebook.isOffline),
        localVersion: Value(notebook.localVersion),
        serverVersion: Value(notebook.serverVersion),
        lastSyncAt: Value(notebook.lastSyncAt),
        noteCount: Value(notebook.noteCount),
        isDefault: Value(notebook.isDefault),
        sortOrder: Value(notebook.sortOrder),
        noteIds: Value(notebook.noteIds),
      );
      if (existing == null) {
        await _db!.into(_db!.notebooks).insert(companion);
      } else {
        await (_db!.update(_db!.notebooks)
              ..where((tbl) => tbl.uuid.equals(notebook.uuid)))
            .write(companion);
      }
      _logger.debug('Saved notebook: ${notebook.name}');
    } catch (e) {
      _logger.error('Failed to save notebook: $e');
      rethrow;
    }
  }

  /// Map Drift row to UnifiedNote
  UnifiedNote _noteFromRow(Note row) {
    return UnifiedNote(
      id: row.id,
      uuid: row.uuid,
      title: row.title,
      content: row.content,
      notebookUuid: row.notebookUuid,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deleted: row.deleted,
      isDirty: row.isDirty,
      isOffline: row.isOffline,
      localVersion: row.localVersion,
      serverVersion: row.serverVersion,
      lastSyncAt: row.lastSyncAt,
      tags: row.tags,
      color: row.color,
      priority: row.priority,
      notebookName: row.notebookName,
      noteCount: row.noteCount,
    );
  }

  /// Map Drift row to UnifiedNotebook
  UnifiedNotebook _notebookFromRow(Notebook row) {
    return UnifiedNotebook(
      id: row.id,
      uuid: row.uuid,
      name: row.name,
      description: row.description,
      color: row.color,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deleted: row.deleted,
      isDirty: row.isDirty,
      isOffline: row.isOffline,
      localVersion: row.localVersion,
      serverVersion: row.serverVersion,
      lastSyncAt: row.lastSyncAt,
      noteCount: row.noteCount,
      isDefault: row.isDefault,
      sortOrder: row.sortOrder,
      noteIds: row.noteIds,
    );
  }
}
