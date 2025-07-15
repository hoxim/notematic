import 'api_service.dart';

/// NotebookService is a thin wrapper for HTTP API notebook/note functions.
class NotebookService {
  static final NotebookService _instance = NotebookService._internal();
  factory NotebookService() => _instance;
  NotebookService._internal();
  final _api = ApiService();

  /// Creates a new notebook using HTTP API.
  Future<bool> createNotebook({
    required String name,
    String? description,
    String? color,
  }) async {
    return await _api.createNotebook(
      name: name,
      description: description,
      color: color,
    );
  }

  /// Gets all user notebooks using HTTP API.
  Future<List<dynamic>> getUserNotebooks() async {
    return await _api.getUserNotebooks();
  }

  /// Creates a new note in a notebook using HTTP API.
  Future<bool> createNote({
    required String notebookId,
    required String title,
    required String content,
  }) async {
    return await _api.createNote(
      notebookId: notebookId,
      title: title,
      content: content,
    );
  }

  /// Gets all notes for a notebook using HTTP API.
  Future<List<dynamic>> getNotebookNotes(String notebookId) async {
    return await _api.getNotebookNotes(notebookId);
  }

  /// Creates a default notebook for a new user if none exist.
  Future<void> createDefaultNotebookIfNeeded() async {
    final notebooks = await getUserNotebooks();
    if (notebooks.isEmpty) {
      await createNotebook(name: 'My Notebook');
    }
  }
}
