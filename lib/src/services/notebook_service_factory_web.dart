import 'notebook_service_api.dart';
import '../models/notebook.dart';
import 'interfaces/notebook_service_interface.dart';

INotebookService<Notebook> getNotebookService() => NotebookServiceApi();
