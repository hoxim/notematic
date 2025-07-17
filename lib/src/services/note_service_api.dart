import 'interfaces/note_service_interface.dart';
import '../models/note.dart';
import 'api_service.dart';
import 'dart:convert';

class NoteServiceApi implements INoteService<Note> {
  final ApiService _api = ApiService();

  @override
  Future<void> upsertNote(Note note, {String? notebookUuid}) async {
    // TODO: Implement API call to create/update note
    await _api.post('/notes', body: note.toMap());
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final response = await _api.get('/notes');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('notes')) {
        final notes = data['notes'];
        if (notes is List) {
          return notes
              .whereType<Map<String, dynamic>>()
              .map((n) => Note.fromMap(n))
              .toList();
        }
      }
    }
    return [];
  }

  @override
  Future<List<Note>> getNotesForNotebook(String notebookUuid) async {
    final response = await _api.get('/notebooks/$notebookUuid/notes');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('notes')) {
        final notes = data['notes'];
        if (notes is List) {
          return notes
              .whereType<Map<String, dynamic>>()
              .map((n) => Note.fromMap(n))
              .toList();
        }
      }
    }
    return [];
  }

  @override
  Future<void> deleteNote(String uuid) async {
    // TODO: Implement API call to delete note
    await _api.post('/notes/$uuid/delete');
  }

  @override
  Future<void> syncWithApi() async {
    // No-op for API version
  }
}
