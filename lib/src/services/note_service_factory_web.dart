import 'note_service_api.dart';
import '../models/note.dart';
import 'interfaces/note_service_interface.dart';

INoteService<Note> getNoteService() => NoteServiceApi();
