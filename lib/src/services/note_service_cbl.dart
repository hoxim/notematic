import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import '../models/note.dart';
import 'interfaces/note_service_interface.dart';
import 'package:uuid/uuid.dart';

class NoteServiceCBL implements INoteService<Note> {
  final Database db;
  final Collection collection;
  final _uuid = Uuid();

  NoteServiceCBL(this.db, this.collection);

  @override
  Future<void> upsertNote(Note note, {String? notebookUuid}) async {
    if (notebookUuid != null) {
      note.notebookUuid = notebookUuid;
    }
    if (note.id.isEmpty) {
      note.id = _uuid.v4();
    }
    note.isDirty = true;
    final doc = MutableDocument(note.toMap());
    // Optionally set the id if needed (Couchbase Lite auto-generates if not set)
    await collection.saveDocument(doc);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final query = await db.createQuery('SELECT * FROM ${collection.name}');
    final result = await query.execute();
    final results = await result.allResults();
    return results.map((r) {
      final data = r.toPlainMap()[collection.name];
      return Note.fromMap(
        data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    }).toList();
  }

  @override
  Future<List<Note>> getNotesForNotebook(String notebookUuid) async {
    final query = await db.createQuery('''
      SELECT * FROM ${collection.name} WHERE notebookUuid = "$notebookUuid"
    ''');
    final result = await query.execute();
    final results = await result.allResults();
    return results.map((r) {
      final data = r.toPlainMap()[collection.name];
      return Note.fromMap(
        data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    }).toList();
  }

  @override
  Future<void> deleteNote(String id) async {
    final doc = await collection.document(id);
    if (doc != null) {
      final note = Note.fromMap(doc.toPlainMap());
      note.deleted = true;
      note.updatedAt = DateTime.now();
      note.isDirty = true;
      final updatedDoc = MutableDocument(note.toMap());
      // Optionally set the id if needed
      await collection.saveDocument(updatedDoc);
    }
  }

  @override
  Future<void> syncWithApi() async {
    // TODO: Implement your custom sync logic with notematic-api
  }
}
