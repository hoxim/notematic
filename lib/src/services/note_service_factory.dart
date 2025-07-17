import 'package:flutter/foundation.dart' show kIsWeb;
import 'interfaces/note_service_interface.dart';
import 'note_service_api.dart';
import '../models/note.dart';

export 'note_service_factory_mobile.dart'
    if (dart.library.html) 'note_service_factory_web.dart';

// On mobile/desktop: Future<INoteService<Note>> getNoteService()
// On web: INoteService<Note> getNoteService()
