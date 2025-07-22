import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

final notebooksProvider = StateNotifierProvider<NotebooksNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return NotebooksNotifier(ref);
});

class NotebooksNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;

  NotebooksNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadNotebooks();
  }

  Future<void> _loadNotebooks() async {
    try {
      state = const AsyncValue.loading();
      final storage = _ref.read(unifiedStorageServiceProvider);
      final notebooks = await storage.getAllNotebooks();
      state = AsyncValue.data(
          notebooks.map((notebook) => notebook.toMap()).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadNotebooks();
  }

  Future<void> createNotebook({
    required String name,
    String? description,
    String? color,
    bool isDefault = false,
    int? sortOrder,
  }) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.createNotebook(
        name: name,
        description: description,
        color: color,
        isDefault: isDefault,
        sortOrder: sortOrder,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateNotebook(String uuid, Map<String, dynamic> updates) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      final notebook = await storage.getNotebookByUuid(uuid);
      if (notebook != null) {
        notebook.update(
          name: updates['name'],
          description: updates['description'],
          color: updates['color'],
          isDefault: updates['isDefault'],
          sortOrder: updates['sortOrder'],
        );
        await storage.updateNotebook(notebook);
        await refresh();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteNotebook(String uuid) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.deleteNotebook(uuid);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> getNotebookByUuid(String uuid) async {
    final storage = _ref.read(unifiedStorageServiceProvider);
    final notebook = await storage.getNotebookByUuid(uuid);
    if (notebook != null) {
      return notebook.toMap();
    } else {
      throw Exception('Notebook not found');
    }
  }
}
