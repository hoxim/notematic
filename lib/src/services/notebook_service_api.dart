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
    // TODO: Implement API call to create notebook
    await _api.post(
      '/notebooks',
      body: {'name': name, 'description': description, 'color': color},
    );
  }

  @override
  Future<List<Notebook>> getUserNotebooks() async {
    final response = await _api.get('/notebooks');
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
    await _api.post('/notebooks/$uuid/delete');
  }

  @override
  Future<void> createDefaultNotebookIfNeeded() async {
    // TODO: Implement API call to create default notebook if needed
    // Możesz wywołać createNotebook jeśli lista notatników jest pusta
  }

  @override
  Future<void> syncWithApi() async {
    // No-op for API version
  }
}
