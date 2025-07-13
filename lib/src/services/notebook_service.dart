import 'package:notematic/src/services/api_service.dart';
import 'package:notematic/src/services/token_service.dart';
import 'package:notematic/src/services/logger_service.dart';

class NotebookService {
  static final NotebookService _instance = NotebookService._internal();
  factory NotebookService() => _instance;
  NotebookService._internal();
  final _logger = LoggerService();
  final _apiService = ApiService();

  Future<bool> createNotebook({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      return await withValidToken((accessToken) async {
        await _apiService.createNotebook(
          accessToken: accessToken,
          name: name,
          description: description,
          color: color,
        );
        return true;
      });
    } catch (e) {
      _logger.error('Create notebook error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotebooks() async {
    try {
      return await withValidToken((accessToken) async {
        return await _apiService.getUserNotebooks(accessToken);
      });
    } catch (e) {
      _logger.error('Get notebooks error: $e');
      return [];
    }
  }

  Future<bool> createNote({
    required String notebookId,
    required String title,
    required String content,
  }) async {
    try {
      return await withValidToken((accessToken) async {
        await _apiService.createNote(
          accessToken: accessToken,
          notebookId: notebookId,
          title: title,
          content: content,
        );
        return true;
      });
    } catch (e) {
      _logger.error('Create note error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getNotebookNotes(String notebookId) async {
    try {
      return await withValidToken((accessToken) async {
        return await _apiService.getNotebookNotes(notebookId, accessToken);
      });
    } catch (e) {
      _logger.error('Get notes error: $e');
      return [];
    }
  }

  Future<bool> createDefaultNotebook() async {
    try {
      final notebooks = await getUserNotebooks();
      if (notebooks.isNotEmpty) {
        return true;
      }
      _logger.info('Creating default notebook for new user');
      final success = await createNotebook(
        name: 'General',
        description: 'Default notebook for your notes',
        color: '#2196F3',
      );
      if (success) {
        _logger.info('Default notebook created successfully');
      } else {
        _logger.error('Failed to create default notebook');
      }
      return success;
    } catch (e) {
      _logger.error('Error creating default notebook: $e');
      return false;
    }
  }
}
