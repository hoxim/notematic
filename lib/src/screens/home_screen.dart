import 'package:flutter/material.dart';
import '../services/note_service_factory.dart';
import '../services/notebook_service_factory.dart';
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


  dynamic _noteService;
  dynamic _notebookService;
  final LoggerService _logger = LoggerService();

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
    _noteService = await getNoteService();
    _notebookService = await getNotebookService();
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
          await _notebookService.createDefaultNotebookIfNeeded();
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
      final notebooks = await _notebookService.getUserNotebooks();
      _logger.info('Loaded notebooks: $notebooks');

      // Parse the API response structure
      List<dynamic> mappedNotebooks = [];
      if (notebooks.isNotEmpty && notebooks.first is Map) {
        final firstItem = notebooks.first as Map;
        if (firstItem.containsKey('notebooks')) {
          mappedNotebooks = (firstItem['notebooks'] as List?) ?? [];
        } else {
          mappedNotebooks = notebooks;
        }
      } else {
        mappedNotebooks = notebooks;
      }

      Map<String, List<dynamic>> notesMap = {};
      for (final notebook in mappedNotebooks) {
        _logger.info(
          'Notebook runtimeType: ${notebook.runtimeType}, value: ${notebook.toString()}',
        );
        // Try different possible ID field names
        final id = (notebook is Map
            ? (notebook['id'] ??
                  notebook['_id'] ??
                  notebook['notebook_id'] ??
                  notebook['uuid'])
            : (notebook.id ??
                  notebook._id ??
                  notebook.notebook_id ??
                  notebook.uuid));
        _logger.info('Extracted notebook id: $id');
        if (id != null && id is String) {
          _logger.info('Getting notes for notebook $id');
          final notes = await _noteService.getNotesForNotebook(id);
          _logger.info('Loaded notes for notebook $id: $notes');
          notesMap[id] = notes;
        } else {
          _logger.error('Notebook structure: $notebook');
        }
      }
      setState(() {
        _notebooks = mappedNotebooks;
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
    Navigator.of(context)
        .pushNamed(
          '/create-note',
          arguments: {
            'notebookId': _notebooks.first['id'] ?? _notebooks.first['_id'],
          },
        )
        .then((value) {
          if (value == true) {
            _loadNotebooksAndNotes();
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
            await _notebookService.createNotebook(
              name,
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
            await _loadNotebooksAndNotes();
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
      final notebookId = (notebook is Map
          ? (notebook['id'] ?? notebook['_id'])
          : notebook.id ?? notebook._id);
      final notes = _notebookNotes[notebookId] ?? [];
      final notebookName =
          (notebook is Map ? notebook['name'] : notebook.name) ??
          'Unknown Notebook';

      for (final note in notes) {
        final title =
            (note is Map ? (note['title'] as String?) : note.title)
                ?.toLowerCase() ??
            '';
        final content =
            (note is Map ? (note['content'] as String?) : note.content)
                ?.toLowerCase() ??
            '';
        final searchLower = query.toLowerCase();

        if (title.contains(searchLower) || content.contains(searchLower)) {
          // Add notebook info to the note for display
          final noteWithNotebook = note is Map
              ? Map<String, dynamic>.from(note)
              : note.toMap();
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
      isSyncEnabled = prefs.getBool('isSyncEnabled') ?? true;
    });
  }

  Future<void> _setSyncFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSyncEnabled', value);
    setState(() {
      isSyncEnabled = value;
    });
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
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: widget.themeMode == ThemeMode.dark
                ? const Icon(Icons.wb_sunny_outlined)
                : const Icon(Icons.nightlight_round),
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Light mode'
                : 'Dark mode',
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
      final notebookId = (notebook is Map
          ? (notebook['id'] ?? notebook['_id'])
          : notebook.id ?? notebook._id);
      final notebookName =
          (notebook is Map ? notebook['name'] : notebook.name) ??
          'Unknown Notebook';
      if (notebookId != null) {
        final notes = _notebookNotes[notebookId] ?? [];
        for (final note in notes) {
          final noteWithNotebook = note is Map
              ? Map<String, dynamic>.from(note)
              : note.toMap();
          noteWithNotebook['notebookName'] = notebookName;
          noteWithNotebook['notebookId'] = notebookId;
          allNotes.add(noteWithNotebook);
        }
      }
    }
    return allNotes;
  }


}
