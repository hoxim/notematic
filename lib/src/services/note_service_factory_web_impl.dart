import 'interfaces/note_service_interface.dart';
import '../models/note.dart';
import 'note_service_api.dart';

// For web platform, returns API implementation directly
Future<INoteService<Note>> getNoteService() async {
  return NoteServiceApi();
}
