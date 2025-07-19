import 'interfaces/notebook_service_interface.dart';
import '../models/notebook.dart';
import 'api_service.dart';
import 'dart:convert';

class NotebookServiceApi implements INotebookService<Notebook> {
  final ApiService _api = ApiService();

  @override
  Future<void> createNotebook(
    String name, {
    String? description,
    String? color,
  }) async {
    final response = await _api.post(
      '/protected/notebooks',
      body: {'name': name, 'description': description, 'color': color},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Failed to create notebook: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<List<Notebook>> getUserNotebooks() async {
    final response = await _api.get('/protected/notebooks');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('notebooks')) {
        final notebooks = data['notebooks'];
        if (notebooks is List) {
          return notebooks
              .whereType<Map<String, dynamic>>()
              .map((n) => Notebook.fromMap(n))
              .toList();
        }
      }
    }
    return [];
  }

  @override
  Future<void> deleteNotebook(String uuid) async {
    // TODO: Implement API call to delete notebook
    await _api.post('/protected/notebooks/$uuid/delete');
  }

  @override
  Future<void> createDefaultNotebookIfNeeded() async {
    // TODO: Implement API call to create default notebook if needed
    // Call createNotebook if the list of notebooks is empty
  }

  @override
  Future<void> syncWithApi() async {
    // No-op for API version
  }

  /// Create a notebook with offline flag set to true
  static Notebook createOfflineNotebook({
    required String name,
    String? description,
    String? color,
  }) {
    return Notebook(
      uuid: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Temporary local ID
      name: name,
      description: description,
      color: color,
      updatedAt: DateTime.now(),
      isOffline: true,
      isDirty: true, // Mark as needing sync when online
    );
  }
}
