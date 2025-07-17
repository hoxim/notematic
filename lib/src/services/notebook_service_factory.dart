import 'package:flutter/foundation.dart' show kIsWeb;
import 'interfaces/notebook_service_interface.dart';
import 'notebook_service_api.dart';
import '../models/notebook.dart';

export 'notebook_service_factory_mobile.dart'
    if (dart.library.html) 'notebook_service_factory_web.dart';

// On mobile/desktop: Future<INotebookService<Notebook>> getNotebookService()
// On web: INotebookService<Notebook> getNotebookService()
