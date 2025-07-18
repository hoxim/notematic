import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';

// This file delegates to the appropriate platform implementation
// using conditional imports
export 'notebook_service_factory_impl.dart'
    if (dart.library.html) 'notebook_service_factory_web_impl.dart';
