import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'notebook_service.dart';

Future<INotebookService<Notebook>> getNotebookService(
    {bool offline = true}) async {
  // Always use API for now
  return NotebookServiceApi() as INotebookService<Notebook>;
}
