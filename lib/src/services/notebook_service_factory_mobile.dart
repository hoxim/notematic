import 'notebook_service_cbl.dart';
import '../models/notebook.dart';
import 'interfaces/notebook_service_interface.dart';
import 'package:cbl/cbl.dart';

Future<INotebookService<Notebook>> getNotebookService() async {
  final db = await Database.openAsync('notematic-notebooks');
  final collection = await db.defaultCollection;
  return NotebookServiceCBL(db, collection);
}
