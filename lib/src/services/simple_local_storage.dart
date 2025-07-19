import '../models/note_local.dart';
import '../models/notebook_local.dart';
import 'logger_service.dart';

class SimpleLocalStorageService {
  final LoggerService _logger = LoggerService();

  // In-memory storage for now
  static final List<NoteLocal> _notes = [];
  static final List<NotebookLocal> _notebooks = [];

  // Note operations
  Future<void> saveNote(NoteLocal note) async {
    // Remove existing note with same UUID
    _notes.removeWhere((n) => n.uuid == note.uuid);
    _notes.add(note);
    _logger.info('Saved note locally: ${note.title}');
  }

  Future<List<NoteLocal>> getAllNotes() async {
    return List.from(_notes);
  }

  Future<List<NoteLocal>> getNotesForNotebook(String notebookUuid) async {
    return _notes.where((note) => note.notebookUuid == notebookUuid).toList();
  }

  Future<List<NoteLocal>> getDirtyNotes() async {
    return _notes.where((note) => note.isDirty).toList();
  }

  Future<NoteLocal?> getNoteByUuid(String uuid) async {
    try {
      return _notes.firstWhere((note) => note.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteNote(String uuid) async {
    _notes.removeWhere((note) => note.uuid == uuid);
    _logger.info('Deleted note locally: $uuid');
  }

  // Notebook operations
  Future<void> saveNotebook(NotebookLocal notebook) async {
    // Remove existing notebook with same UUID
    _notebooks.removeWhere((n) => n.uuid == notebook.uuid);
    _notebooks.add(notebook);
    _logger.info('Saved notebook locally: ${notebook.name}');
  }

  Future<List<NotebookLocal>> getAllNotebooks() async {
    return List.from(_notebooks);
  }

  Future<List<NotebookLocal>> getDirtyNotebooks() async {
    return _notebooks.where((notebook) => notebook.isDirty).toList();
  }

  Future<NotebookLocal?> getNotebookByUuid(String uuid) async {
    try {
      return _notebooks.firstWhere((notebook) => notebook.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteNotebook(String uuid) async {
    _notebooks.removeWhere((notebook) => notebook.uuid == uuid);
    _logger.info('Deleted notebook locally: $uuid');
  }

  // Sync operations
  Future<void> syncNotesToLocal(List<Map<String, dynamic>> apiNotes) async {
    for (final apiNote in apiNotes) {
      final note = NoteLocal.fromApiMap(apiNote);
      note.isOffline = false; // Mark as synced from server
      note.isDirty = false;
      await saveNote(note);
    }
    _logger.info('Synced ${apiNotes.length} notes from API to local');
  }

  Future<void> syncNotebooksToLocal(
      List<Map<String, dynamic>> apiNotebooks) async {
    for (final apiNotebook in apiNotebooks) {
      final notebook = NotebookLocal.fromApiMap(apiNotebook);
      notebook.isOffline = false; // Mark as synced from server
      notebook.isDirty = false;
      await saveNotebook(notebook);
    }
    _logger.info('Synced ${apiNotebooks.length} notebooks from API to local');
  }

  // Get all data (local + offline)
  Future<List<NoteLocal>> getAllNotesWithOffline() async {
    return List.from(_notes);
  }

  Future<List<NotebookLocal>> getAllNotebooksWithOffline() async {
    return List.from(_notebooks);
  }

  // Clear all data
  Future<void> clearAllData() async {
    _notes.clear();
    _notebooks.clear();
    _logger.info('Cleared all local data');
  }

  // Get sync status
  Future<Map<String, int>> getSyncStatus() async {
    final totalNotes = _notes.length;
    final dirtyNotes = _notes.where((note) => note.isDirty).length;
    final totalNotebooks = _notebooks.length;
    final dirtyNotebooks =
        _notebooks.where((notebook) => notebook.isDirty).length;

    return {
      'totalNotes': totalNotes,
      'dirtyNotes': dirtyNotes,
      'totalNotebooks': totalNotebooks,
      'dirtyNotebooks': dirtyNotebooks,
    };
  }

  // Add some test data
  Future<void> addTestData() async {
    // Add test notebook
    final testNotebook = NotebookLocal.createOffline(
      name: 'Test Offline Notebook',
      description: 'Created offline for testing',
      color: '#FF5722',
    );
    await saveNotebook(testNotebook);

    // Add test note
    final testNote = NoteLocal.createOffline(
      title: 'Test Offline Note',
      content:
          'This is a test note created offline to demonstrate the offline indicator.',
      notebookUuid: testNotebook.uuid,
    );
    await saveNote(testNote);

    _logger.info('Added test offline data');
  }
}
