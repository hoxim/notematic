import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

final notesProvider = StateNotifierProvider<NotesNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return NotesNotifier(ref);
});

class NotesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;

  NotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      state = const AsyncValue.loading();
      final storage = _ref.read(unifiedStorageServiceProvider);
      final notes = await storage.getAllNotes();
      // Filtrowanie notatek z deleted: true
      state = AsyncValue.data(
        notes.where((n) => !n.deleted).map((note) => note.toMap()).toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadNotes();
  }

  Future<void> createNote({
    required String title,
    required String content,
    required String notebookUuid,
    List<String> tags = const [],
    String? color,
    int? priority,
  }) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.createNote(
        title: title,
        content: content,
        notebookUuid: notebookUuid,
        tags: tags,
        color: color,
        priority: priority,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateNote(String uuid, Map<String, dynamic> updates) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      final note = await storage.getNoteByUuid(uuid);
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
        await storage.updateNote(note);
        await refresh();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteNote(String uuid) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.deleteNote(uuid);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> getNoteByUuid(String uuid) async {
    final storage = _ref.read(unifiedStorageServiceProvider);
    final note = await storage.getNoteByUuid(uuid);
    if (note != null) {
      return note.toMap();
    } else {
      throw Exception('Note not found');
    }
  }
}
