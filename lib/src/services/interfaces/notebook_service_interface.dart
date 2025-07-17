import '../../models/notebook.dart';

abstract class INotebookService<T> {
  Future<void> createNotebook(
    String name, {
    String? description,
    String? color,
  });
  Future<List<T>> getUserNotebooks();
  Future<void> deleteNotebook(String uuid);
  Future<void> createDefaultNotebookIfNeeded();
  Future<void> syncWithApi();
}
