import 'interfaces/note_service_interface.dart';
import '../models/note.dart';

// This file delegates to the appropriate platform implementation
// using conditional imports
export 'note_service_factory_impl.dart'
    if (dart.library.html) 'note_service_factory_web_impl.dart';
