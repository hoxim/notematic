import 'simple_local_storage.dart';
import 'api_service.dart';
import 'logger_service.dart';
import '../models/note_local.dart';
import '../models/notebook_local.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  final SimpleLocalStorageService _localStorage = SimpleLocalStorageService();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  /// Check if sync is enabled and API is available
  Future<bool> isOnlineMode() async {
    try {
      // Check if sync is enabled
      final prefs = await SharedPreferences.getInstance();
      final isSyncEnabled = prefs.getBool('isSyncEnabled') ?? false;

      if (!isSyncEnabled) {
        _logger.info('Sync is disabled - offline mode');
        return false;
      }

      // Check if API is available
      final isApiAvailable = await _apiService.isApiAvailable();
      return isApiAvailable;
    } catch (e) {
      _logger.error('Error checking online mode: $e');
      return false; // Default to offline mode on error
    }
  }

  /// Sync local changes to API
  Future<void> syncToApi() async {
    if (!await isOnlineMode()) {
      _logger.warning('Cannot sync to API - offline mode');
      return;
    }

    try {
      // Sync dirty notes
      final dirtyNotes = await _localStorage.getDirtyNotes();
      for (final note in dirtyNotes) {
        try {
          await _apiService.post('/protected/notes', body: note.toApiMap());
          note.markAsSynced(DateTime.now().millisecondsSinceEpoch.toString());
          await _localStorage.saveNote(note);
          _logger.info('Synced note to API: ${note.title}');
        } catch (e) {
          _logger.error('Failed to sync note to API: ${note.title}, error: $e');
        }
      }

      // Sync dirty notebooks
      final dirtyNotebooks = await _localStorage.getDirtyNotebooks();
      for (final notebook in dirtyNotebooks) {
        try {
          await _apiService.post('/protected/notebooks',
              body: notebook.toApiMap());
          notebook
              .markAsSynced(DateTime.now().millisecondsSinceEpoch.toString());
          await _localStorage.saveNotebook(notebook);
          _logger.info('Synced notebook to API: ${notebook.name}');
        } catch (e) {
          _logger.error(
              'Failed to sync notebook to API: ${notebook.name}, error: $e');
        }
      }

      _logger.info('Sync to API completed');
    } catch (e) {
      _logger.error('Error during sync to API: $e');
    }
  }

  /// Sync API changes to local
  Future<void> syncFromApi() async {
    _logger.info('Starting sync from API...');

    final isOnline = await isOnlineMode();
    _logger.info('Online mode: $isOnline');

    if (!isOnline) {
      _logger.warning('Cannot sync from API - offline mode');
      return;
    }

    try {
      // Sync notes from API - get all notebooks first, then notes for each
      _logger.info('Fetching notebooks from API...');
      final notebooksResponse = await _apiService.get('/protected/notebooks');
      _logger.info(
          'Notebooks API response status: ${notebooksResponse.statusCode}');
      _logger.info('Notebooks API response body: ${notebooksResponse.body}');

      if (notebooksResponse.statusCode == 200) {
        final notebooksData = jsonDecode(notebooksResponse.body);
        if (notebooksData is Map<String, dynamic> &&
            notebooksData.containsKey('notebooks')) {
          final apiNotebooks =
              (notebooksData['notebooks'] as List).cast<Map<String, dynamic>>();
          _logger.info('Found ${apiNotebooks.length} notebooks from API');

          // Sync notebooks to local storage
          _logger.info('Syncing notebooks to local storage...');
          await _localStorage.syncNotebooksToLocal(apiNotebooks);

          // Get notes for each notebook
          List<Map<String, dynamic>> allApiNotes = [];
          for (final notebook in apiNotebooks) {
            final notebookId = notebook['_id'];
            _logger.info('Fetching notes for notebook: $notebookId');

            final notesResponse =
                await _apiService.get('/protected/notebooks/$notebookId/notes');
            _logger.info(
                'Notes API response status for notebook $notebookId: ${notesResponse.statusCode}');

            if (notesResponse.statusCode == 200) {
              final notesData = jsonDecode(notesResponse.body);
              if (notesData is Map<String, dynamic> &&
                  notesData.containsKey('notes')) {
                final apiNotes =
                    (notesData['notes'] as List).cast<Map<String, dynamic>>();
                _logger.info(
                    'Found ${apiNotes.length} notes for notebook $notebookId');
                allApiNotes.addAll(apiNotes);
              }
            } else {
              _logger.error(
                  'Failed to fetch notes for notebook $notebookId: ${notesResponse.statusCode}');
            }
          }

          _logger.info('Total notes found from API: ${allApiNotes.length}');
          await _localStorage.syncNotesToLocal(allApiNotes);
        } else {
          _logger
              .warning('No notebooks found in API response or invalid format');
        }
      } else {
        _logger.error(
            'Failed to fetch notebooks from API: ${notebooksResponse.statusCode}');
      }

      _logger.info('Sync from API completed');
    } catch (e) {
      _logger.error('Error during sync from API: $e');
    }
  }

  /// Full sync (both directions)
  Future<void> fullSync() async {
    _logger.info('Starting full sync...');

    // First sync from API to get latest changes
    await syncFromApi();

    // Then sync local changes to API
    await syncToApi();

    _logger.info('Full sync completed');
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final localStatus = await _localStorage.getSyncStatus();
    final isOnline = await isOnlineMode();

    return {
      ...localStatus,
      'isOnline': isOnline,
      'canSync': isOnline,
    };
  }

  /// Create note (offline or online)
  Future<void> createNote({
    required String title,
    required String content,
    required String notebookUuid,
  }) async {
    final isOnline = await isOnlineMode();

    if (isOnline) {
      // Create online
      final note = NoteLocal(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        notebookUuid: notebookUuid,
        isOffline: false,
        isDirty: false,
      );

      try {
        await _apiService.post('/protected/notes', body: note.toApiMap());
        await _localStorage.saveNote(note);
        _logger.info('Created note online: $title');
      } catch (e) {
        _logger.error('Failed to create note online, creating offline: $e');
        // Fallback to offline
        final offlineNote = NoteLocal.createOffline(
          title: title,
          content: content,
          notebookUuid: notebookUuid,
        );
        await _localStorage.saveNote(offlineNote);
      }
    } else {
      // Create offline
      final offlineNote = NoteLocal.createOffline(
        title: title,
        content: content,
        notebookUuid: notebookUuid,
      );
      await _localStorage.saveNote(offlineNote);
      _logger.info('Created note offline: $title');
    }
  }

  /// Create notebook (offline or online)
  Future<void> createNotebook({
    required String name,
    String? description,
    String? color,
  }) async {
    final isOnline = await isOnlineMode();

    if (isOnline) {
      // Create online
      final notebook = NotebookLocal(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        color: color,
        updatedAt: DateTime.now(),
        isOffline: false,
        isDirty: false,
      );

      try {
        await _apiService.post('/protected/notebooks',
            body: notebook.toApiMap());
        await _localStorage.saveNotebook(notebook);
        _logger.info('Created notebook online: $name');
      } catch (e) {
        _logger.error('Failed to create notebook online, creating offline: $e');
        // Fallback to offline
        final offlineNotebook = NotebookLocal.createOffline(
          name: name,
          description: description,
          color: color,
        );
        await _localStorage.saveNotebook(offlineNotebook);
      }
    } else {
      // Create offline
      final offlineNotebook = NotebookLocal.createOffline(
        name: name,
        description: description,
        color: color,
      );
      await _localStorage.saveNotebook(offlineNotebook);
      _logger.info('Created notebook offline: $name');
    }
  }

  /// Get all notes (local + offline)
  Future<List<NoteLocal>> getAllNotes() async {
    // First sync from API to get latest data
    await syncFromApi();
    return await _localStorage.getAllNotesWithOffline();
  }

  /// Get all notebooks (local + offline)
  Future<List<NotebookLocal>> getAllNotebooks() async {
    // First sync from API to get latest data
    await syncFromApi();
    return await _localStorage.getAllNotebooksWithOffline();
  }

  /// Get notes for specific notebook
  Future<List<NoteLocal>> getNotesForNotebook(String notebookUuid) async {
    // First sync from API to get latest data
    await syncFromApi();
    return await _localStorage.getNotesForNotebook(notebookUuid);
  }

  /// Delete note (offline or online)
  Future<void> deleteNote(String noteUuid) async {
    final isOnline = await isOnlineMode();

    if (isOnline) {
      try {
        // Delete from API
        await _apiService.delete('/protected/notes/$noteUuid');
        _logger.info('Deleted note from API: $noteUuid');
      } catch (e) {
        _logger.error('Failed to delete note from API: $noteUuid, error: $e');
      }
    }

    // Delete from local storage
    await _localStorage.deleteNote(noteUuid);
    _logger.info('Deleted note locally: $noteUuid');
  }

  /// Sync specific note to API
  Future<void> syncNoteToApi(String noteUuid) async {
    if (!await isOnlineMode()) {
      _logger.warning('Cannot sync note to API - offline mode');
      return;
    }

    try {
      // Get the note from local storage
      final note = await _localStorage.getNoteByUuid(noteUuid);
      if (note == null) {
        _logger.error('Note not found for sync: $noteUuid');
        return;
      }

      // Send to API
      await _apiService.post('/protected/notes', body: note.toApiMap());
      note.markAsSynced(DateTime.now().millisecondsSinceEpoch.toString());
      await _localStorage.saveNote(note);
      _logger.info('Synced note to API: ${note.title}');
    } catch (e) {
      _logger.error('Failed to sync note to API: $noteUuid, error: $e');
    }
  }
}
