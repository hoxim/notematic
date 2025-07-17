import 'package:cbl/cbl.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import '../models/notebook.dart';
import 'interfaces/notebook_service_interface.dart';
import 'package:uuid/uuid.dart';

class NotebookServiceCBL implements INotebookService<Notebook> {
  final Database db;
  final Collection collection;
  final _uuid = Uuid();

  NotebookServiceCBL(this.db, this.collection);

  @override
  Future<void> createNotebook(
    String name, {
    String? description,
    String? color,
  }) async {
    final notebook = Notebook(
      id: _uuid.v4(),
      name: name,
      description: description,
      color: color,
      updatedAt: DateTime.now(),
    );
    final doc = MutableDocument(notebook.toMap());
    await collection.saveDocument(doc);
  }

  @override
  Future<List<Notebook>> getUserNotebooks() async {
    final query = await db.createQuery('SELECT * FROM ${collection.name}');
    final result = await query.execute();
    final results = await result.allResults();
    return results.map((r) {
      final data = r.toPlainMap()[collection.name];
      return Notebook.fromMap(
        data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    }).toList();
  }

  @override
  Future<void> deleteNotebook(String id) async {
    final doc = await collection.document(id);
    if (doc != null) {
      final notebook = Notebook.fromMap(doc.toPlainMap());
      notebook.deleted = true;
      notebook.updatedAt = DateTime.now();
      notebook.isDirty = true;
      final updatedDoc = MutableDocument(notebook.toMap());
      await collection.saveDocument(updatedDoc);
    }
  }

  @override
  Future<void> createDefaultNotebookIfNeeded() async {
    final query = await db.createQuery('SELECT * FROM ${collection.name}');
    final result = await query.execute();
    final results = await result.allResults();
    if (results.isEmpty) {
      await createNotebook(
        'My Notes',
        description: 'Default notebook for your notes',
        color: '#2196F3',
      );
    }
  }

  @override
  Future<void> syncWithApi() async {
    // TODO: Implement your custom sync logic with notematic-api
  }
}
