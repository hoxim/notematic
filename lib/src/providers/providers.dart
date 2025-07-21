import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logger_service.dart';
import '../services/api_service.dart';
import '../services/unified_storage_service.dart';
import '../services/unified_sync_service.dart';
import '../services/token_service.dart';
import '../services/simple_local_storage.dart';

// ===== SERVICE PROVIDERS =====

/// Logger service provider
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});

/// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Unified storage service provider
final unifiedStorageServiceProvider = Provider<UnifiedStorageService>((ref) {
  return UnifiedStorageService();
});

/// Unified sync service provider
final unifiedSyncServiceProvider = Provider<UnifiedSyncService>((ref) {
  return UnifiedSyncService();
});

/// Token service provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

/// Simple local storage provider
final simpleLocalStorageProvider = Provider<SimpleLocalStorage>((ref) {
  return SimpleLocalStorage();
});

// ===== APP STATE PROVIDERS =====

/// Notes provider - manages all notes
final notesProvider = StateNotifierProvider<NotesNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return NotesNotifier(ref);
});

class NotesNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref _ref;

  NotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      state = const AsyncValue.loading();
      final storage = _ref.read(unifiedStorageServiceProvider);
      final notes = await storage.getAllNotes();
      state = AsyncValue.data(notes.map((note) => note.toMap()).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh notes
  Future<void> refresh() async {
    await _loadNotes();
  }

  /// Create new note
  Future<void> createNote({
    required String title,
    required String content,
    required String notebookUuid,
    List<String> tags = const [],
    String? color,
    int? priority,
  }) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.createNote(
        title: title,
        content: content,
        notebookUuid: notebookUuid,
        tags: tags,
        color: color,
        priority: priority,
      );
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update note
  Future<void> updateNote(String uuid, Map<String, dynamic> updates) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      final note = await storage.getNoteByUuid(uuid);
      if (note != null) {
        note.update(
          title: updates['title'],
          content: updates['content'],
          notebookUuid: updates['notebookUuid'],
          tags: updates['tags'] != null
              ? List<String>.from(updates['tags'])
              : null,
          color: updates['color'],
          priority: updates['priority'],
        );
        await storage.updateNote(note);
        await refresh();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete note
  Future<void> deleteNote(String uuid) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.deleteNote(uuid);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Notebooks provider - manages all notebooks
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

  /// Refresh notebooks
  Future<void> refresh() async {
    await _loadNotebooks();
  }

  /// Create new notebook
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

  /// Update notebook
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

  /// Delete notebook
  Future<void> deleteNotebook(String uuid) async {
    try {
      final storage = _ref.read(unifiedStorageServiceProvider);
      await storage.deleteNotebook(uuid);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Sync enabled provider
final syncEnabledProvider =
    StateNotifierProvider<SyncEnabledNotifier, AsyncValue<bool>>((ref) {
  return SyncEnabledNotifier(ref);
});

class SyncEnabledNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  SyncEnabledNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSyncEnabled();
  }

  Future<void> _loadSyncEnabled() async {
    try {
      state = const AsyncValue.loading();
      final storage = _ref.read(simpleLocalStorageProvider);
      final isEnabled = await storage.getBool('isSyncEnabled') ?? false;
      state = AsyncValue.data(isEnabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle sync
  Future<void> toggleSync() async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      final currentValue = await storage.getBool('isSyncEnabled') ?? false;
      await storage.setBool('isSyncEnabled', !currentValue);
      state = AsyncValue.data(!currentValue);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Set sync enabled
  Future<void> setSyncEnabled(bool enabled) async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      await storage.setBool('isSyncEnabled', enabled);
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Loading provider
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool loading) {
    state = loading;
  }
}

/// Search provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setResults(List<Map<String, dynamic>> results) {
    state = state.copyWith(results: results);
  }

  void setSearching(bool searching) {
    state = state.copyWith(isSearching: searching);
  }

  void clearSearch() {
    state = const SearchState();
  }
}

/// FAB expanded provider
final fabExpandedProvider =
    StateNotifierProvider<FabExpandedNotifier, bool>((ref) {
  return FabExpandedNotifier();
});

class FabExpandedNotifier extends StateNotifier<bool> {
  FabExpandedNotifier() : super(false);

  void toggle() {
    print('fabExpandedProvider.toggle() called, current: '
        ' [33m$state [0m');
    state = !state;
    print('fabExpandedProvider new state: '
        ' [32m$state [0m');
  }

  void setExpanded(bool expanded) {
    state = expanded;
  }
}

/// User provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void setUser(String email) {
    state = state.copyWith(email: email, isLoggedIn: true);
  }

  void logout() {
    state = const UserState();
  }

  void setLoginState(bool isLoggedIn) {
    state = state.copyWith(isLoggedIn: isLoggedIn);
  }
}

// ===== FORM STATE PROVIDERS =====

/// Create note form provider
final createNoteFormProvider =
    StateNotifierProvider<CreateNoteFormNotifier, CreateNoteFormState>((ref) {
  return CreateNoteFormNotifier();
});

class CreateNoteFormNotifier extends StateNotifier<CreateNoteFormState> {
  CreateNoteFormNotifier() : super(const CreateNoteFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setNotebookUuid(String notebookUuid) {
    state = state.copyWith(notebookUuid: notebookUuid);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void setColor(String? color) {
    state = state.copyWith(color: color);
  }

  void setPriority(int? priority) {
    state = state.copyWith(priority: priority);
  }

  void reset() {
    state = const CreateNoteFormState();
  }

  bool get isValid =>
      state.title.isNotEmpty &&
      state.content.isNotEmpty &&
      state.notebookUuid.isNotEmpty;
}

/// Notebook form provider
final notebookFormProvider =
    StateNotifierProvider<NotebookFormNotifier, NotebookFormState>((ref) {
  return NotebookFormNotifier();
});

class NotebookFormNotifier extends StateNotifier<NotebookFormState> {
  NotebookFormNotifier() : super(const NotebookFormState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String? description) {
    state = state.copyWith(description: description);
  }

  void setColor(String? color) {
    state = state.copyWith(color: color);
  }

  void setIsDefault(bool isDefault) {
    state = state.copyWith(isDefault: isDefault);
  }

  void setSortOrder(int? sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void reset() {
    state = const NotebookFormState();
  }

  bool get isValid => state.name.isNotEmpty;
}

// ===== STATE CLASSES =====

/// Search state
class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// User state
class UserState {
  final String email;
  final bool isLoggedIn;

  const UserState({
    this.email = '',
    this.isLoggedIn = false,
  });

  UserState copyWith({
    String? email,
    bool? isLoggedIn,
  }) {
    return UserState(
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// Create note form state
class CreateNoteFormState {
  final String title;
  final String content;
  final String notebookUuid;
  final List<String> tags;
  final String? color;
  final int? priority;

  const CreateNoteFormState({
    this.title = '',
    this.content = '',
    this.notebookUuid = '',
    this.tags = const [],
    this.color,
    this.priority,
  });

  CreateNoteFormState copyWith({
    String? title,
    String? content,
    String? notebookUuid,
    List<String>? tags,
    String? color,
    int? priority,
  }) {
    return CreateNoteFormState(
      title: title ?? this.title,
      content: content ?? this.content,
      notebookUuid: notebookUuid ?? this.notebookUuid,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }
}

/// Notebook form state
class NotebookFormState {
  final String name;
  final String? description;
  final String? color;
  final bool isDefault;
  final int? sortOrder;

  const NotebookFormState({
    this.name = '',
    this.description,
    this.color,
    this.isDefault = false,
    this.sortOrder,
  });

  NotebookFormState copyWith({
    String? name,
    String? description,
    String? color,
    bool? isDefault,
    int? sortOrder,
  }) {
    return NotebookFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
