import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/user_profile_menu.dart';
import '../components/notebook_dialog.dart';
import '../components/app_about_dialog.dart';
import '../components/sync_toggle.dart';
import '../components/search_bar.dart';
import '../components/notes_list_view.dart';
import '../components/search_results_list.dart';
import '../components/create_fab.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

const noteColors = [
  // Each entry: {'light': Color, 'dark': Color}
  {'light': Color(0xFFFFF59D), 'dark': Color(0xFF7E7E3A)}, // Yellow
  {'light': Color(0xFF90CAF9), 'dark': Color(0xFF274472)}, // Blue
  {'light': Color(0xFFA5D6A7), 'dark': Color(0xFF356859)}, // Green
  {'light': Color(0xFFEF9A9A), 'dark': Color(0xFF7B3B3B)}, // Red
  {'light': Color(0xFFCE93D8), 'dark': Color(0xFF5E366E)}, // Purple
  {'light': Color(0xFFE0E0E0), 'dark': Color(0xFF424242)}, // Grey
];

Color getNotebookColor(int colorIndex, bool isDark) {
  final idx = colorIndex % noteColors.length;
  return isDark ? noteColors[idx]['dark']! : noteColors[idx]['light']!;
}

Color getTextColor(Color bg, bool isDark) {
  // If background is dark, use white; if light, use black
  return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? _userEmail;
  bool _defaultNotebookChecked = false; // Prevents multiple creations
  List<dynamic> _notebooks = [];
  Map<String, List<dynamic>> _notebookNotes = {};
  bool _isLoading = true;
  bool isSyncEnabled = true; // global sync flag

  // FAB animation
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isFabExpanded = false;

  // Search functionality
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // About dialog state

  final LoggerService _logger = LoggerService();
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _initServices();
    _loadSyncFlag();
  }

  Future<void> _initServices() async {
    await _loadUserInfo();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userEmail = await TokenService().getUserId();
      if (userEmail != null) {
        setState(() {
          _userEmail = userEmail;
        });
        _logger.info('User loaded:  [38;5;2m$_userEmail [0m');
        if (!_defaultNotebookChecked) {
          _defaultNotebookChecked = true;
          // Default notebook creation is handled by SyncService
        }
        await _loadNotebooksAndNotes();
      }
    } catch (e) {
      _logger.error('Failed to load user info: $e');
    }
  }

  Future<void> _loadNotebooksAndNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Use SyncService to get all data with single sync
      final allData = await _syncService.getAllDataWithSync();
      final allNotes = allData['notes'] as List<dynamic>;
      final allNotebooks = allData['notebooks'] as List<dynamic>;

      _logger.info('Loaded notebooks: $allNotebooks');
      _logger.info('Loaded notes: $allNotes');

      // Group notes by notebook
      Map<String, List<dynamic>> notesMap = {};
      for (final notebook in allNotebooks) {
        final notebookId = notebook.uuid;
        final notesForNotebook =
            allNotes.where((note) => note.notebookUuid == notebookId).toList();
        notesMap[notebookId] = notesForNotebook;
        _logger
            .info('Notes for notebook $notebookId: ${notesForNotebook.length}');
      }

      setState(() {
        _notebooks = allNotebooks;
        _notebookNotes = notesMap;
        _isLoading = false;
      });
      _logger.info('Final notebooks: $_notebooks');
      _logger.info('Final notes map: $_notebookNotes');
    } catch (e) {
      _logger.error('Failed to load notebooks or notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotebooksAndNotesWithoutSync() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Use SyncService to get all data without sync
      final allNotes = await _syncService.getAllNotes();
      final allNotebooks = await _syncService.getAllNotebooks();

      _logger.info('Loaded notebooks without sync: $allNotebooks');
      _logger.info('Loaded notes without sync: $allNotes');

      // Group notes by notebook
      Map<String, List<dynamic>> notesMap = {};
      for (final notebook in allNotebooks) {
        final notebookId = notebook.uuid;
        final notesForNotebook =
            allNotes.where((note) => note.notebookUuid == notebookId).toList();
        notesMap[notebookId] = notesForNotebook;
        _logger
            .info('Notes for notebook $notebookId: ${notesForNotebook.length}');
      }

      setState(() {
        _notebooks = allNotebooks;
        _notebookNotes = notesMap;
        _isLoading = false;
      });
      _logger.info('Final notebooks: $_notebooks');
      _logger.info('Final notes map: $_notebookNotes');
    } catch (e) {
      _logger.error('Failed to load notebooks or notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openNoteDetails(Map<String, dynamic> note) {
    // Placeholder: show snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Open note: ${note['title']}')));
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });

    if (_isFabExpanded) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _createNote() {
    _toggleFab();
    if (_notebooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a notebook first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to create note screen with first notebook selected
    Navigator.of(context).pushNamed(
      '/create-note',
      arguments: {
        'notebookId': _notebooks.first.uuid,
      },
    ).then((value) {
      if (value == true) {
        _loadNotebooksAndNotesWithoutSync();
      }
    });
  }

  void _createNotebook() {
    _toggleFab();
    _showCreateNotebookDialog();
  }

  void _showCreateNotebookDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotebookDialog(
          onCreate: (name, description, color) async {
            try {
              _logger.info('Creating notebook via SyncService');
              await _syncService.createNotebook(
                name: name,
                description: description,
                color: color,
              );

              _logger.info('Notebook created successfully');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notebook created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              await _loadNotebooksAndNotesWithoutSync();
            } catch (e) {
              _logger.error('Failed to create notebook: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to create notebook'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Search through all notes in all notebooks
    List<Map<String, dynamic>> results = [];
    for (final notebook in _notebooks) {
      final notebookId = notebook.uuid;
      final notes = _notebookNotes[notebookId] ?? [];
      final notebookName = notebook.name ?? 'Unknown Notebook';

      for (final note in notes) {
        final title = note.title.toLowerCase();
        final content = note.content.toLowerCase();
        final searchLower = query.toLowerCase();

        if (title.contains(searchLower) || content.contains(searchLower)) {
          // Add notebook info to the note for display
          final noteWithNotebook = note.toMap();
          noteWithNotebook['notebookName'] = notebookName;
          noteWithNotebook['notebookId'] = notebookId;
          results.add(noteWithNotebook);
        }
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
    });
    _searchController.clear();
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await TokenService().clearToken();
      _logger.info('User logged out');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _logger.error('Failed to logout: $e');
    }
  }

  void _showProfile() {
    _logger.info('Profile button pressed');
    // TODO: Navigate to profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile feature coming soon!')),
    );
  }

  void _showSettings() {
    _logger.info('Settings button pressed');
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon!')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AppAboutDialog(),
    );
  }

  Future<void> _loadSyncFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSyncEnabled = prefs.getBool('isSyncEnabled') ?? false;
    });
  }

  Future<void> _setSyncFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSyncEnabled', value);
    setState(() {
      isSyncEnabled = value;
    });

    // Clear online mode cache when sync settings change
    _syncService.clearOnlineModeCache();
  }

  /// Check if sync is enabled and API is available
  Future<bool> _isOfflineMode() async {
    try {
      // Check if sync is disabled
      if (!isSyncEnabled) {
        return true; // Offline mode when sync is disabled
      }

      // Check if API is available
      final apiService = ApiService();
      final isApiAvailable = await apiService.isApiAvailable();

      return !isApiAvailable; // Offline mode when API is not available
    } catch (e) {
      _logger.error('Error checking offline mode: $e');
      return true; // Default to offline mode on error
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    try {
      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content:
                Text('Are you sure you want to delete "${note['title']}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) return;

      // Delete the note
      await _syncService.deleteNote(note['id']);
      _logger.info('Deleted note: ${note['title']}');

      // Reload data without additional sync
      await _loadNotebooksAndNotesWithoutSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note "${note['title']}" deleted')),
        );
      }
    } catch (e) {
      _logger.error('Failed to delete note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete note')),
        );
      }
    }
  }

  Future<void> _syncNote(Map<String, dynamic> note) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronizing note...')),
        );
      }

      // Sync the note
      await _syncService.syncNoteToApi(note['id']);
      _logger.info('Synced note: ${note['title']}');

      // Reload data without additional sync
      await _loadNotebooksAndNotesWithoutSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note "${note['title']}" synchronized')),
        );
      }
    } catch (e) {
      _logger.error('Failed to sync note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to synchronize note')),
        );
      }
    }
  }

  Future<void> _syncNow() async {
    try {
      _logger.info('Manual sync requested');

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronizing...')),
        );
      }

      // Perform full sync
      await _syncService.fullSync();

      // Reload data without additional sync
      await _loadNotebooksAndNotesWithoutSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.error('Manual sync failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notematic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          SyncToggle(
            value: isSyncEnabled,
            onChanged: _setSyncFlag,
            onSyncNow: _syncNow,
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: widget.themeMode == ThemeMode.dark
                ? const Icon(Icons.wb_sunny_outlined)
                : const Icon(Icons.nightlight_round),
            tooltip:
                widget.themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
          ),
          // User profile menu
          UserProfileMenu(
            userEmail: _userEmail,
            onProfileTap: _showProfile,
            onSettingsTap: _showSettings,
            onAboutTap: _showAboutDialog,
            onLogoutTap: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field at the top
                  NotesSearchBar(
                    controller: _searchController,
                    onChanged: _performSearch,
                    onClear: _clearSearch,
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${_userEmail ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _isSearching
                        ? SearchResultsList(
                            searchResults: _searchResults,
                            searchQuery: _searchQuery,
                            onNoteTap: _openNoteDetails,
                          )
                        : NotesListView(
                            notes: _getAllNotes(),
                            onNoteTap: _openNoteDetails,
                            onDeleteNote: _deleteNote,
                            onSyncNote: _syncNote,
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: CreateFAB(
        isExpanded: _isFabExpanded,
        animation: _fabAnimation,
        onToggle: _toggleFab,
        onCreateNote: _createNote,
        onCreateNotebook: _createNotebook,
      ),
    );
  }

  List<Map<String, dynamic>> _getAllNotes() {
    List<Map<String, dynamic>> allNotes = [];
    for (final notebook in _notebooks) {
      final notebookId = notebook.uuid;
      final notebookName = notebook.name ?? 'Unknown Notebook';
      final notes = _notebookNotes[notebookId] ?? [];
      for (final note in notes) {
        final noteWithNotebook = note.toMap();
        noteWithNotebook['notebookName'] = notebookName;
        noteWithNotebook['notebookId'] = notebookId;
        allNotes.add(noteWithNotebook);
      }
    }
    return allNotes;
  }
}
