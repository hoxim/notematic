import '../../models/note.dart';

abstract class INoteService<T> {
  Future<void> upsertNote(T note, {String? notebookUuid});
  Future<List<T>> getAllNotes();
  Future<List<T>> getNotesForNotebook(String notebookUuid);
  Future<void> deleteNote(String uuid);
  Future<void> syncWithApi();
}
