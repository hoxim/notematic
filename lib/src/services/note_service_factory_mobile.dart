import 'note_service_cbl.dart';
import '../models/note.dart';
import 'interfaces/note_service_interface.dart';
import 'package:cbl/cbl.dart';

Future<INoteService<Note>> getNoteService() async {
  final db = await Database.openAsync('notematic-notes');
  final collection = await db.defaultCollection;
  return NoteServiceCBL(db, collection);
}
