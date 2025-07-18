import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'package:cbl/cbl.dart';
import 'notebook_service_cbl.dart';

Future<INotebookService<Notebook>> getNotebookService() async {
  // Use Couchbase Lite for mobile and desktop platforms
  final db = await Database.openAsync('notematic-notebooks');
  final collection = await db.defaultCollection;
  return NotebookServiceCBL(db, collection);
}
