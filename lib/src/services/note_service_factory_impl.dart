import 'interfaces/note_service_interface.dart';
import '../models/note.dart';
import 'note_service_api.dart';
import 'package:cbl/cbl.dart';
import 'note_service_cbl.dart';

Future<INoteService<Note>> getNoteService() async {
  // Use Couchbase Lite for mobile and desktop platforms
  final db = await Database.openAsync('notematic-notes');
  final collection = await db.defaultCollection;
  return NoteServiceCBL(db, collection);
}
