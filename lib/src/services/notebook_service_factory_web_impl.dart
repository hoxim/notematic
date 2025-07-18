import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'notebook_service_api.dart';

// For web platform, returns API implementation directly
Future<INotebookService<Notebook>> getNotebookService({bool offline = false}) async {
  // Web zawsze online
  return NotebookServiceApi();
}
