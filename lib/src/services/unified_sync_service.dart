import 'unified_storage_service.dart';
import 'api_service.dart';
import '../models/unified_note.dart';
import '../models/unified_notebook.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Unified sync service that handles all synchronization logic
/// This service provides a clean interface for sync operations
/// and handles conflict resolution between local and server data
class UnifiedSyncService {
  final UnifiedStorageService _storage = UnifiedStorageService();
  final LoggerService _logger;
  final ApiService _apiService;

  UnifiedSyncService(this._apiService, this._logger);

  // Cache for online mode status
  bool? _cachedOnlineMode;
  DateTime? _lastOnlineCheck;

  /// Initialize the sync service
  Future<void> initialize() async {
    await _storage.initialize();
    _logger.info('UnifiedSyncService initialized');
  }

  /// Check if sync is enabled
  Future<bool> isSyncEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isSyncEnabled') ?? false;
    } catch (e) {
      _logger.error('Failed to check sync enabled: $e');
      return false;
    }
  }

  /// Set sync enabled
  Future<void> setSyncEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSyncEnabled', enabled);
      _logger.info('Sync enabled set to: $enabled');
    } catch (e) {
      _logger.error('Failed to set sync enabled: $e');
    }
  }

  /// Check if online mode is available
  Future<bool> isOnlineMode() async {
    try {
      // Cache the result for 30 seconds to avoid too many checks
      if (_cachedOnlineMode != null && _lastOnlineCheck != null) {
        final timeSinceLastCheck = DateTime.now().difference(_lastOnlineCheck!);
        if (timeSinceLastCheck.inSeconds < 30) {
          return _cachedOnlineMode!;
        }
      }

      final isOnline = await _apiService.isOnline();
      _cachedOnlineMode = isOnline;
      _lastOnlineCheck = DateTime.now();

      _logger.info('Online mode check: $isOnline');
      return isOnline;
    } catch (e) {
      _logger.error('Failed to check online mode: $e');
      return false;
    }
  }

  /// Clear online mode cache
  void clearOnlineModeCache() {
    _cachedOnlineMode = null;
    _lastOnlineCheck = null;
    _logger.debug('Online mode cache cleared');
  }

  /// Perform full sync (both directions)
  Future<void> fullSync() async {
    try {
      final isEnabled = await isSyncEnabled();
      if (!isEnabled) {
        _logger.info('Sync is disabled, skipping full sync');
        return;
      }

      final isOnline = await isOnlineMode();
      if (!isOnline) {
        _logger.info('Not online, skipping full sync');
        return;
      }

      _logger.info('Starting full sync...');

      // Check if we have dirty items first
      final dirtyNotes = await _storage.getDirtyNotes();
      final dirtyNotebooks = await _storage.getDirtyNotebooks();

      if (dirtyNotes.isEmpty && dirtyNotebooks.isEmpty) {
        _logger.info('No dirty items to sync, skipping server sync');
        return;
      }

      _logger.info(
          'Found ${dirtyNotes.length} dirty notes and ${dirtyNotebooks.length} dirty notebooks');

      // Sync from server to local (only if we have local changes)
      if (dirtyNotes.isNotEmpty || dirtyNotebooks.isNotEmpty) {
        await _syncFromServer();
      }

      // Sync from local to server
      await _syncToServer();

      _logger.info('Full sync completed successfully');
    } catch (e) {
      _logger.error('Failed to perform full sync: $e');
      rethrow;
    }
  }

  /// Sync data from server to local with version comparison
  Future<void> _syncFromServer() async {
    try {
      _logger.info('Syncing from server to local...');

      // Get notes from server
      final apiNotes = await _apiService.getNotes();
      if (apiNotes.isNotEmpty) {
        await _storage.syncNotesFromApiWithVersionCheck(apiNotes);
        _logger.info('Synced ${apiNotes.length} notes from server');
      }

      // Get notebooks from server
      final apiNotebooks = await _apiService.getNotebooks();
      if (apiNotebooks.isNotEmpty) {
        await _storage.syncNotebooksFromApiWithVersionCheck(apiNotebooks);
        _logger.info('Synced ${apiNotebooks.length} notebooks from server');
      }
    } catch (e) {
      _logger.error('Failed to sync from server: $e');
      rethrow;
    }
  }

  /// Sync data from local to server (only dirty items)
  Future<void> _syncToServer() async {
    try {
      _logger.info('Syncing from local to server...');

      int notesSynced = 0;
      int notebooksSynced = 0;

      // Get dirty notes (need sync)
      final dirtyNotes = await _storage.getDirtyNotes();
      _logger.info('Found ${dirtyNotes.length} dirty notes to sync');

      for (final note in dirtyNotes) {
        try {
          if (note.deleted) {
            if (note.isOffline) {
              // For offline notes that are deleted, just remove them locally
              await _storage.deleteNote(note.uuid);
              _logger.info('Offline note deleted locally: ${note.title}');
            } else {
              // For online notes that are deleted, try to delete from server
              try {
                await _apiService.deleteNote(note.uuid);
                await _storage.markNoteAsSynced(
                    note.uuid, DateTime.now().toIso8601String());
                _logger.info('Note deleted and synced: ${note.title}');
                notesSynced++;
              } catch (e) {
                _logger.warning(
                    'Failed to delete note from server: ${note.title}, error: $e');
                // Mark as synced anyway to avoid retrying
                await _storage.markNoteAsSynced(
                    note.uuid, DateTime.now().toIso8601String());
              }
            }
          } else if (note.isOffline) {
            // Create new note on server
            try {
              final apiNote = await _apiService.createNote(note.toApiMap());
              await _storage.markNoteAsSynced(note.uuid,
                  apiNote['version'] ?? DateTime.now().toIso8601String());
              _logger.info('Note created and synced: ${note.title}');
              notesSynced++;
            } catch (e) {
              _logger.warning(
                  'Failed to create note on server: ${note.title}, error: $e');
            }
          } else {
            // Update existing note on server
            try {
              final apiNote =
                  await _apiService.updateNote(note.uuid, note.toApiMap());
              await _storage.markNoteAsSynced(note.uuid,
                  apiNote['version'] ?? DateTime.now().toIso8601String());
              _logger.info('Note updated and synced: ${note.title}');
              notesSynced++;
            } catch (e) {
              _logger.warning(
                  'Failed to update note on server: ${note.title}, error: $e');
            }
          }
        } catch (e) {
          _logger.error('Failed to sync note ${note.title}: $e');
        }
      }

      // Get dirty notebooks (need sync)
      final dirtyNotebooks = await _storage.getDirtyNotebooks();
      _logger.info('Found ${dirtyNotebooks.length} dirty notebooks to sync');

      for (final notebook in dirtyNotebooks) {
        try {
          if (notebook.deleted) {
            if (notebook.isOffline) {
              // For offline notebooks that are deleted, just remove them locally
              await _storage.deleteNotebook(notebook.uuid);
              _logger
                  .info('Offline notebook deleted locally: ${notebook.name}');
            } else {
              // For online notebooks that are deleted, try to delete from server
              try {
                await _apiService.deleteNotebook(notebook.uuid);
                await _storage.markNotebookAsSynced(
                    notebook.uuid, DateTime.now().toIso8601String());
                _logger.info('Notebook deleted and synced: ${notebook.name}');
                notebooksSynced++;
              } catch (e) {
                _logger.warning(
                    'Failed to delete notebook from server: ${notebook.name}, error: $e');
                // Mark as synced anyway to avoid retrying
                await _storage.markNotebookAsSynced(
                    notebook.uuid, DateTime.now().toIso8601String());
              }
            }
          } else if (notebook.isOffline) {
            // Create new notebook on server
            try {
              final apiNotebook =
                  await _apiService.createNotebook(notebook.toApiMap());
              await _storage.markNotebookAsSynced(notebook.uuid,
                  apiNotebook['version'] ?? DateTime.now().toIso8601String());
              _logger.info('Created notebook on server: ${notebook.name}');
              notebooksSynced++;
            } catch (e) {
              _logger.warning(
                  'Failed to create notebook on server: ${notebook.name}, error: $e');
            }
          } else {
            // Update existing notebook on server
            try {
              final apiNotebook = await _apiService.updateNotebook(
                  notebook.uuid, notebook.toApiMap());
              await _storage.markNotebookAsSynced(notebook.uuid,
                  apiNotebook['version'] ?? DateTime.now().toIso8601String());
              _logger.info('Updated notebook on server: ${notebook.name}');
              notebooksSynced++;
            } catch (e) {
              _logger.warning(
                  'Failed to update notebook on server: ${notebook.name}, error: $e');
            }
          }
        } catch (e) {
          _logger.error('Failed to sync notebook ${notebook.name}: $e');
        }
      }

      if (notesSynced > 0 || notebooksSynced > 0) {
        _logger.info(
            'Synced $notesSynced notes and $notebooksSynced notebooks to server');
      } else {
        _logger.info('No items synced to server');
      }
    } catch (e) {
      _logger.error('Failed to sync to server: $e');
      rethrow;
    }
  }

  /// Create note with sync
  Future<void> createNote({
    required String title,
    required String content,
    required String notebookUuid,
    List<String> tags = const [],
    String? color,
    int? priority,
  }) async {
    try {
      // Create note locally first
      final note = await _storage.createNote(
        title: title,
        content: content,
        notebookUuid: notebookUuid,
        tags: tags,
        color: color,
        priority: priority,
      );

      // Try to sync to server if online
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      if (isEnabled && isOnline) {
        try {
          final apiNote = await _apiService.createNote(note.toApiMap());
          await _storage.markNoteAsSynced(note.uuid,
              apiNote['version'] ?? DateTime.now().toIso8601String());
          _logger.info('Note created and synced: ${note.title}');
        } catch (e) {
          _logger.warning(
              'Note created locally but failed to sync: ${note.title}');
        }
      } else {
        _logger.info('Note created locally (offline mode): ${note.title}');
      }
    } catch (e) {
      _logger.error('Failed to create note: $e');
      rethrow;
    }
  }

  /// Create notebook with sync
  Future<void> createNotebook({
    required String name,
    String? description,
    String? color,
    bool isDefault = false,
    int? sortOrder,
  }) async {
    try {
      // Create notebook locally first
      final notebook = await _storage.createNotebook(
        name: name,
        description: description,
        color: color,
        isDefault: isDefault,
        sortOrder: sortOrder,
      );

      // Try to sync to server if online
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      if (isEnabled && isOnline) {
        try {
          final apiNotebook =
              await _apiService.createNotebook(notebook.toApiMap());
          await _storage.markNotebookAsSynced(notebook.uuid,
              apiNotebook['version'] ?? DateTime.now().toIso8601String());
          _logger.info('Notebook created and synced: ${notebook.name}');
        } catch (e) {
          _logger.warning(
              'Notebook created locally but failed to sync: ${notebook.name}');
        }
      } else {
        _logger
            .info('Notebook created locally (offline mode): ${notebook.name}');
      }
    } catch (e) {
      _logger.error('Failed to create notebook: $e');
      rethrow;
    }
  }

  /// Update note with sync
  Future<void> updateNote(String uuid, Map<String, dynamic> updates) async {
    try {
      final note = await _storage.getNoteByUuid(uuid);
      if (note != null) {
        note.update(
          title: updates['title'],
          content: updates['content'],
          notebookUuid: updates['notebookUuid'],
          tags: updates['tags'] != null
              ? List<String>.from(updates['tags'])
              : null,
          color: updates['color'],
          priority: updates['priority'],
        );
        await _storage.updateNote(note);

        // Try to sync to server if online
        final isEnabled = await isSyncEnabled();
        final isOnline = await isOnlineMode();

        if (isEnabled && isOnline) {
          try {
            final apiNote = await _apiService.updateNote(uuid, note.toApiMap());
            await _storage.markNoteAsSynced(
                uuid, apiNote['version'] ?? DateTime.now().toIso8601String());
            _logger.info('Note updated and synced: ${note.title}');
          } catch (e) {
            _logger.warning(
                'Note updated locally but failed to sync: ${note.title}');
          }
        } else {
          _logger.info('Note updated locally (offline mode): ${note.title}');
        }
      }
    } catch (e) {
      _logger.error('Failed to update note: $e');
      rethrow;
    }
  }

  /// Update notebook with sync
  Future<void> updateNotebook(String uuid, Map<String, dynamic> updates) async {
    try {
      final notebook = await _storage.getNotebookByUuid(uuid);
      if (notebook != null) {
        notebook.update(
          name: updates['name'],
          description: updates['description'],
          color: updates['color'],
          isDefault: updates['isDefault'],
          sortOrder: updates['sortOrder'],
        );
        await _storage.updateNotebook(notebook);

        // Try to sync to server if online
        final isEnabled = await isSyncEnabled();
        final isOnline = await isOnlineMode();

        if (isEnabled && isOnline) {
          try {
            final apiNotebook =
                await _apiService.updateNotebook(uuid, notebook.toApiMap());
            await _storage.markNotebookAsSynced(uuid,
                apiNotebook['version'] ?? DateTime.now().toIso8601String());
            _logger.info('Notebook updated and synced: ${notebook.name}');
          } catch (e) {
            _logger.warning(
                'Notebook updated locally but failed to sync: ${notebook.name}');
          }
        } else {
          _logger.info(
              'Notebook updated locally (offline mode): ${notebook.name}');
        }
      }
    } catch (e) {
      _logger.error('Failed to update notebook: $e');
      rethrow;
    }
  }

  /// Delete note with sync
  Future<void> deleteNote(String uuid) async {
    try {
      await _storage.deleteNote(uuid);

      // Try to sync to server if online
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      if (isEnabled && isOnline) {
        try {
          await _apiService.deleteNote(uuid);
          _logger.info('Note deleted and synced: $uuid');
        } catch (e) {
          _logger.warning('Note deleted locally but failed to sync: $uuid');
        }
      } else {
        _logger.info('Note deleted locally (offline mode): $uuid');
      }
    } catch (e) {
      _logger.error('Failed to delete note: $e');
      rethrow;
    }
  }

  /// Delete notebook with sync
  Future<void> deleteNotebook(String uuid) async {
    try {
      await _storage.deleteNotebook(uuid);

      // Try to sync to server if online
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      if (isEnabled && isOnline) {
        try {
          await _apiService.deleteNotebook(uuid);
          _logger.info('Notebook deleted and synced: $uuid');
        } catch (e) {
          _logger.warning('Notebook deleted locally but failed to sync: $uuid');
        }
      } else {
        _logger.info('Notebook deleted locally (offline mode): $uuid');
      }
    } catch (e) {
      _logger.error('Failed to delete notebook: $e');
      rethrow;
    }
  }

  /// Get all data with sync
  Future<Map<String, dynamic>> getAllDataWithSync() async {
    try {
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      if (isEnabled && isOnline) {
        // Perform sync first
        await fullSync();
      }

      // Get all data from local storage
      final notes = await _storage.getAllNotes();
      final notebooks = await _storage.getAllNotebooks();

      return {
        'notes': notes.map((note) => note.toMap()).toList(),
        'notebooks': notebooks.map((notebook) => notebook.toMap()).toList(),
      };
    } catch (e) {
      _logger.error('Failed to get all data with sync: $e');
      rethrow;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final storageStats = await _storage.getSyncStats();
      final isEnabled = await isSyncEnabled();
      final isOnline = await isOnlineMode();

      return {
        ...storageStats,
        'syncEnabled': isEnabled,
        'isOnline': isOnline,
        'lastSync': _lastOnlineCheck?.toIso8601String(),
      };
    } catch (e) {
      _logger.error('Failed to get sync stats: $e');
      return {};
    }
  }

  /// Resolve conflicts between local and server data
  Future<void> resolveConflicts() async {
    try {
      _logger.info('Starting conflict resolution...');

      // Get all local data
      final localNotes = await _storage.getAllNotes();
      final localNotebooks = await _storage.getAllNotebooks();

      // Get all server data
      final apiNotes = await _apiService.getNotes();
      final apiNotebooks = await _apiService.getNotebooks();

      // Resolve note conflicts
      for (final localNote in localNotes) {
        final serverNote = apiNotes.firstWhere(
          (apiNote) => apiNote['id'] == localNote.uuid,
          orElse: () => {},
        );

        if (serverNote.isNotEmpty) {
          final localVersion = DateTime.parse(
              localNote.localVersion ?? localNote.updatedAt.toIso8601String());
          final serverVersion = DateTime.parse(serverNote['updatedAt'] ??
              serverNote['version'] ??
              DateTime.now().toIso8601String());

          if (serverVersion.isAfter(localVersion)) {
            // Server version is newer, update local
            final updatedNote = UnifiedNote.fromApi(serverNote);
            await _storage.updateNote(updatedNote);
            _logger.info(
                'Resolved conflict for note: ${localNote.title} (server version wins)');
          } else if (localVersion.isAfter(serverVersion)) {
            // Local version is newer, update server
            try {
              await _apiService.updateNote(
                  localNote.uuid, localNote.toApiMap());
              _logger.info(
                  'Resolved conflict for note: ${localNote.title} (local version wins)');
            } catch (e) {
              _logger.error(
                  'Failed to update server for note: ${localNote.title}');
            }
          }
        }
      }

      // Resolve notebook conflicts
      for (final localNotebook in localNotebooks) {
        final serverNotebook = apiNotebooks.firstWhere(
          (apiNotebook) => apiNotebook['id'] == localNotebook.uuid,
          orElse: () => {},
        );

        if (serverNotebook.isNotEmpty) {
          final localVersion = DateTime.parse(localNotebook.localVersion ??
              localNotebook.updatedAt.toIso8601String());
          final serverVersion = DateTime.parse(serverNotebook['updatedAt'] ??
              serverNotebook['version'] ??
              DateTime.now().toIso8601String());

          if (serverVersion.isAfter(localVersion)) {
            // Server version is newer, update local
            final updatedNotebook = UnifiedNotebook.fromApi(serverNotebook);
            await _storage.updateNotebook(updatedNotebook);
            _logger.info(
                'Resolved conflict for notebook: ${localNotebook.name} (server version wins)');
          } else if (localVersion.isAfter(serverVersion)) {
            // Local version is newer, update server
            try {
              await _apiService.updateNotebook(
                  localNotebook.uuid, localNotebook.toApiMap());
              _logger.info(
                  'Resolved conflict for notebook: ${localNotebook.name} (local version wins)');
            } catch (e) {
              _logger.error(
                  'Failed to update server for notebook: ${localNotebook.name}');
            }
          }
        }
      }

      _logger.info('Conflict resolution completed');
    } catch (e) {
      _logger.error('Failed to resolve conflicts: $e');
      rethrow;
    }
  }

  /// Synchronize a single note online (create/update/delete)
  Future<void> syncSingleNote(String uuid) async {
    // Check if sync is enabled and online
    final isEnabled = await isSyncEnabled();
    final isOnline = await isOnlineMode();

    if (!isEnabled || !isOnline) {
      throw Exception('Sync is disabled or offline');
    }

    final note = await _storage.getNoteByUuid(uuid);
    if (note == null) throw Exception('Note not found');
    if (note.deleted) {
      await _apiService.deleteNote(note.uuid);
      await _storage.markNoteAsSynced(
          note.uuid, DateTime.now().toIso8601String());
      _logger.info('Note deleted and synced: ${note.title}');
    } else if (note.isOffline) {
      final apiNote = await _apiService.createNote(note.toApiMap());
      await _storage.markNoteAsSynced(
          note.uuid, apiNote['version'] ?? DateTime.now().toIso8601String());
      _logger.info('Note created and synced: ${note.title}');
    } else {
      final apiNote = await _apiService.updateNote(note.uuid, note.toApiMap());
      await _storage.markNoteAsSynced(
          note.uuid, apiNote['version'] ?? DateTime.now().toIso8601String());
      _logger.info('Note updated and synced: ${note.title}');
    }
  }

  /// Synchronize a single notebook online (create/update/delete)
  Future<void> syncSingleNotebook(String uuid) async {
    // Check if sync is enabled and online
    final isEnabled = await isSyncEnabled();
    final isOnline = await isOnlineMode();

    if (!isEnabled || !isOnline) {
      throw Exception('Sync is disabled or offline');
    }

    final notebook = await _storage.getNotebookByUuid(uuid);
    if (notebook == null) throw Exception('Notebook not found');
    if (notebook.deleted) {
      await _apiService.deleteNotebook(notebook.uuid);
      await _storage.markNotebookAsSynced(
          notebook.uuid, DateTime.now().toIso8601String());
      _logger.info('Notebook deleted and synced: ${notebook.name}');
    } else if (notebook.isOffline) {
      final apiNotebook = await _apiService.createNotebook(notebook.toApiMap());
      await _storage.markNotebookAsSynced(notebook.uuid,
          apiNotebook['version'] ?? DateTime.now().toIso8601String());
      _logger.info('Notebook created and synced: ${notebook.name}');
    } else {
      final apiNotebook =
          await _apiService.updateNotebook(notebook.uuid, notebook.toApiMap());
      await _storage.markNotebookAsSynced(notebook.uuid,
          apiNotebook['version'] ?? DateTime.now().toIso8601String());
      _logger.info('Notebook updated and synced: ${notebook.name}');
    }
  }
}
