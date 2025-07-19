import 'interfaces/note_service_interface.dart';
import '../models/note.dart';
import 'note_service.dart';

Future<INoteService<Note>> getNoteService({bool offline = true}) async {
  // Always use API for now
  return NoteServiceApi() as INoteService<Note>;
}
