import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'package:cbl/cbl.dart';
import 'notebook_service_cbl.dart';
import 'notebook_service_api.dart';

Future<INotebookService<Notebook>> getNotebookService({bool offline = true}) async {
  if (offline) {
    // Use Couchbase Lite for mobile and desktop platforms
    final db = await Database.openAsync('notematic-notebooks');
    final collection = await db.defaultCollection;
    return NotebookServiceCBL(db, collection);
  } else {
    return NotebookServiceApi();
  }
}
