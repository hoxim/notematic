import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/logger_service.dart';
import '../services/notebook_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  String? _username;
  final _logger = LoggerService();
  final _notebookService = NotebookService();
  bool _defaultNotebookChecked = false; // Prevents multiple creations
  List<Map<String, dynamic>> _notebooks = [];
  Map<String, List<Map<String, dynamic>>> _notebookNotes = {};
  bool _isLoading = true;
  Map<String, int> _notebookColorIndices = {}; // notebookId -> color index

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final username = await TokenService.getUsernameFromToken();
      if (username != null) {
        setState(() {
          _username = username;
        });
        _logger.info('User loaded: $_username');
        if (!_defaultNotebookChecked) {
          _defaultNotebookChecked = true;
          await _createDefaultNotebook();
        }
        await _loadNotebooksAndNotes();
      }
    } catch (e) {
      _logger.error('Failed to load user info: $e');
    }
  }

  Future<void> _createDefaultNotebook() async {
    try {
      await _notebookService.createDefaultNotebook();
    } catch (e) {
      _logger.error('Failed to create default notebook: $e');
    }
  }

  Future<void> _loadNotebooksAndNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notebooks = await _notebookService.getUserNotebooks();
      // Map id if needed
      final mappedNotebooks =
          notebooks.map((n) {
            if (n['id'] == null && n['_id'] != null) {
              n['id'] = n['_id'];
            }
            return n;
          }).toList();
      Map<String, List<Map<String, dynamic>>> notesMap = {};
      for (final notebook in mappedNotebooks) {
        final id = notebook['id'];
        if (id != null && id is String) {
          final notes = await _notebookService.getNotebookNotes(id);
          notesMap[id] = notes;
        }
      }
      setState(() {
        _notebooks = mappedNotebooks;
        _notebookNotes = notesMap;
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('Failed to load notebooks or notes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNoteForNotebook(String notebookId) {
    Navigator.of(context)
        .pushNamed('/create-note', arguments: {'notebookId': notebookId})
        .then((value) {
          if (value == true) {
            _loadNotebooksAndNotes();
          }
        });
  }

  void _openNoteDetails(Map<String, dynamic> note) {
    // Placeholder: show snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Open note: ${note['title']}')));
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
      await TokenService.clearTokens();
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

  void _showCreateNotebookDialog() {
    _logger.info('Create notebook dialog opened');
    // TODO: Implement create notebook dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create notebook feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notematic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon:
                widget.themeMode == ThemeMode.dark
                    ? const Icon(Icons.wb_sunny_outlined)
                    : const Icon(Icons.nightlight_round),
            tooltip:
                widget.themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
          ),
          // User profile menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User avatar
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _username?.isNotEmpty == true
                          ? _username![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Username (hidden on small screens)
                  if (MediaQuery.of(context).size.width > 400)
                    Text(
                      _username ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            itemBuilder:
                (BuildContext context) => [
                  // User info header
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Signed in',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  // Menu items
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 12),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        const SizedBox(width: 12),
                        const Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20, color: Colors.red),
                        const SizedBox(width: 12),
                        const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                  _showProfile();
                  break;
                case 'settings':
                  _showSettings();
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_username ?? 'User'}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        itemCount: _notebooks.length,
                        itemBuilder: (context, index) {
                          final notebook = _notebooks[index];
                          final notes = _notebookNotes[notebook['id']] ?? [];
                          final notebookId = notebook['id'] as String;
                          final colorIdx =
                              _notebookColorIndices[notebookId] ??
                              (index % noteColors.length);
                          final cardColor = getNotebookColor(colorIdx, isDark);
                          final textColor = getTextColor(cardColor, isDark);
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: cardColor, width: 2),
                            ),
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.black12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          notebook['name'] ?? 'Notebook',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(color: textColor),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => _addNoteForNotebook(
                                              notebook['id'],
                                            ),
                                        icon: const Icon(Icons.note_add),
                                        label: const Text('Add Note'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: cardColor,
                                          foregroundColor: textColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                          side: BorderSide(
                                            color: textColor.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (notes.isEmpty)
                                    Text(
                                      'No notes yet.',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ...notes
                                      .take(3)
                                      .map(
                                        (note) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            note['title'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          subtitle:
                                              note['content'] != null
                                                  ? Text(
                                                    (note['content'] as String)
                                                                .length >
                                                            80
                                                        ? (note['content']
                                                                    as String)
                                                                .substring(
                                                                  0,
                                                                  80,
                                                                ) +
                                                            '...'
                                                        : note['content'],
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.85),
                                                    ),
                                                  )
                                                  : null,
                                          onTap: () => _openNoteDetails(note),
                                        ),
                                      ),
                                  if (notes.length > 3)
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Show all notes for this notebook
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Show all notes coming soon!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Show all notes',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  // Bottom bar with icons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.palette),
                                        color: textColor,
                                        tooltip: 'Change color',
                                        onPressed: () async {
                                          final newColorIdx = await showDialog<
                                            int
                                          >(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Choose color',
                                                ),
                                                content: Wrap(
                                                  spacing: 12,
                                                  children: List.generate(
                                                    noteColors.length,
                                                    (ci) {
                                                      final c =
                                                          getNotebookColor(
                                                            ci,
                                                            isDark,
                                                          );
                                                      return GestureDetector(
                                                        onTap:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(ci),
                                                        child: Container(
                                                          width: 36,
                                                          height: 36,
                                                          decoration: BoxDecoration(
                                                            color: c,
                                                            border: Border.all(
                                                              color:
                                                                  ci == colorIdx
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .transparent,
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  18,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (newColorIdx != null) {
                                            setState(() {
                                              _notebookColorIndices[notebookId] =
                                                  newColorIdx;
                                            });
                                          }
                                        },
                                      ),
                                      // Możesz dodać kolejne ikonki tutaj
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
