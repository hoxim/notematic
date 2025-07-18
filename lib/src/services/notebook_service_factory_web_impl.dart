import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'notebook_service_api.dart';

// For web platform, returns API implementation directly
Future<INotebookService<Notebook>> getNotebookService() async {
  return NotebookServiceApi();
}
