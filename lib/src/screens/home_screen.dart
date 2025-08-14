import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/notebooks_provider.dart';
import '../providers/user_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/form_provider.dart';
import '../providers/storage_provider.dart';
import '../components/notes_grid_view.dart';
import '../components/notes_sectioned_view.dart';
import '../components/notebooks_list_view.dart';
import '../components/search_bar.dart';
import '../components/search_results_list.dart';
import '../components/user_profile_menu.dart';
import '../components/create_fab.dart';
import '../components/sync_toggle.dart';
import '../components/share_note_dialog.dart';
import 'note_view_screen.dart';
import 'create_note_screen.dart';
import 'about_screen.dart';
import 'shared_notes_screen.dart';
import '../providers/sync_service_provider.dart';
import '../services/logger_service.dart';
import '../providers/logger_provider.dart';

/// Home screen that displays notes and notebooks
/// Uses unified models and providers for state management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showNotebooks = false;
  final _searchController = TextEditingController();

  late final LoggerService logger;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize unified services
  Future<void> _initializeServices() async {
    try {
      final syncService = ref.read(unifiedSyncServiceProvider);
      logger = ref.read(loggerServiceProvider);
      await syncService.initialize();
    } catch (e) {
      logger.error('Error initializing sync service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final notebooksAsync = ref.watch(notebooksProvider);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notematic'),
        actions: [
          // Search bar
          Expanded(
            child: NotesSearchBar(
              controller: _searchController,
            ),
          ),
          // Sync toggle
          SyncToggle(
            onSyncNow: () async {
              try {
                final syncService = ref.read(unifiedSyncServiceProvider);
                await syncService.fullSync();

                // Refresh data after sync
                ref.read(notesProvider.notifier).refresh();
                ref.read(notebooksProvider.notifier).refresh();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync completed successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync failed: $e')),
                );
              }
            },
          ),
          // User profile menu
          UserProfileMenu(
            onProfileTap: () {
              // Handle profile tap
            },
            onSettingsTap: () {
              // Handle settings tap
            },
            onSharedNotesTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SharedNotesScreen(),
                ),
              );
            },
            onAboutTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            onLogoutTap: () {
              ref.read(userProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: _buildBody(notesAsync, notebooksAsync, searchState),
      floatingActionButton: CreateFAB(
        animation: const AlwaysStoppedAnimation(1.0),
        onCreateNote: () => _showCreateNoteDialog(context),
        onCreateNotebook: () => _showCreateNotebookDialog(context),
        onToggle: () {}, // usunięto podwójne toggle
      ),
    );
  }

  /// Build the main body content
  Widget _buildBody(
    AsyncValue<List<Map<String, dynamic>>> notesAsync,
    AsyncValue<List<Map<String, dynamic>>> notebooksAsync,
    SearchState searchState,
  ) {
    // Show search results if searching
    if (searchState.query.isNotEmpty) {
      return SearchResultsList(
        onNoteTap: (note) {
          // Handle note tap
        },
      );
    }

    // Show loading state
    if (notesAsync.isLoading || notebooksAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (notesAsync.hasError || notebooksAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              notesAsync.error?.toString() ??
                  notebooksAsync.error?.toString() ??
                  'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(notesProvider.notifier).refresh();
                ref.read(notebooksProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show main content
    return Column(
      children: [
        // Toggle buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showNotebooks = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_showNotebooks ? Theme.of(context).primaryColor : null,
                    foregroundColor: !_showNotebooks ? Colors.white : null,
                  ),
                  child: const Text('Notes'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showNotebooks = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showNotebooks ? Theme.of(context).primaryColor : null,
                    foregroundColor: _showNotebooks ? Colors.white : null,
                  ),
                  child: const Text('Notebooks'),
                ),
              ),
            ],
          ),
        ),
        // View mode toggle (only for notes)
        if (!_showNotebooks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final viewMode = ref.watch(viewModeProvider);
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () => ref
                              .read(viewModeProvider.notifier)
                              .setViewMode(ViewMode.grid),
                          icon: Icon(
                            Icons.grid_view,
                            color: viewMode == ViewMode.grid
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(viewModeProvider.notifier)
                              .setViewMode(ViewMode.sections),
                          icon: Icon(
                            Icons.folder,
                            color: viewMode == ViewMode.sections
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        // Content
        Expanded(
          child: _showNotebooks
              ? NotebooksListView(
                  onNotebookTap: (notebook) {
                    // Handle notebook selection
                    setState(() => _showNotebooks = false);
                  },
                  onEditNotebook: (notebook) {
                    // Handle notebook edit
                    _showEditNotebookDialog(context, notebook);
                  },
                  onDeleteNotebook: (notebook) {
                    // Handle notebook delete
                    _showDeleteNotebookDialog(context, notebook);
                  },
                  onSyncNotebook: (notebook) {
                    // Handle notebook sync
                    _syncNotebook(context, notebook);
                  },
                )
              : Consumer(
                  builder: (context, ref, child) {
                    final viewMode = ref.watch(viewModeProvider);

                    final noteCallbacks = {
                      'onNoteTap': (note) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteViewScreen(note: note),
                          ),
                        );
                      },
                      'onDeleteNote': (note) {
                        _showDeleteNoteDialog(context, note);
                      },
                      'onShareNote': (note) {
                        _showShareNoteDialog(context, note);
                      },
                      'onSyncNote': (note) async {
                        final syncService =
                            ref.read(unifiedSyncServiceProvider);
                        try {
                          await syncService.syncSingleNote(note['uuid']);
                          await ref.read(notesProvider.notifier).refresh();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Note synchronized online!')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sync failed: $e')),
                          );
                        }
                      },
                    };

                    switch (viewMode) {
                      case ViewMode.grid:
                        return NotesGridView(
                          onNoteTap: noteCallbacks['onNoteTap']!,
                          onDeleteNote: noteCallbacks['onDeleteNote']!,
                          onShareNote: noteCallbacks['onShareNote']!,
                          onSyncNote: noteCallbacks['onSyncNote']!,
                        );
                      case ViewMode.sections:
                        return NotesSectionedView(
                          onNoteTap: noteCallbacks['onNoteTap']!,
                          onDeleteNote: noteCallbacks['onDeleteNote']!,
                          onShareNote: noteCallbacks['onShareNote']!,
                          onSyncNote: noteCallbacks['onSyncNote']!,
                        );
                    }
                  },
                ),
        ),
      ],
    );
  }

  /// Show create note dialog
  void _showCreateNoteDialog(BuildContext context) {
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
    );
  }

  /// Show create notebook dialog
  void _showCreateNotebookDialog(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => const CreateNotebookDialog(),
    );
  }

  /// Show edit notebook dialog
  void _showEditNotebookDialog(
      BuildContext context, Map<String, dynamic> notebook) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => CreateNotebookDialog(
        notebookToEdit: notebook,
      ),
    );
  }

  /// Show delete notebook dialog
  void _showDeleteNotebookDialog(
      BuildContext context, Map<String, dynamic> notebook) {
    if (!context.mounted) return;
    final isOffline = notebook['isOffline'] == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notebook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${notebook['name']}"?'),
            const SizedBox(height: 8),
            if (isOffline) ...[
              const Text(
                'This notebook is offline. You can:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Delete locally only'),
              const Text('• Delete locally and online when connected'),
            ] else ...[
              const Text(
                'This will delete the notebook and all its notes.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (isOffline) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(notebooksProvider.notifier)
                    .deleteNotebook(notebook['uuid']);
              },
              child: const Text('Delete Locally'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNotebookWhenOnline(context, notebook);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete When Online'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(notebooksProvider.notifier)
                    .deleteNotebook(notebook['uuid']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ],
      ),
    );
  }

  /// Delete notebook when online (mark for deletion)
  void _deleteNotebookWhenOnline(
      BuildContext context, Map<String, dynamic> notebook) async {
    try {
      // Mark notebook for deletion when online
      final storage = ref.read(unifiedStorageServiceProvider);
      final notebookObj = await storage.getNotebookByUuid(notebook['uuid']);
      if (notebookObj != null) {
        notebookObj.delete();
        await storage.updateNotebook(notebookObj);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Notebook "${notebook['name']}" will be deleted when online'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark notebook for deletion: $e')),
      );
    }
  }

  /// Show delete note dialog
  void _showDeleteNoteDialog(BuildContext context, Map<String, dynamic> note) {
    final isOffline = note['isOffline'] == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${note['title']}"?'),
            const SizedBox(height: 8),
            if (isOffline) ...[
              const Text(
                'This note is offline. You can:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Delete locally only'),
              const Text('• Delete locally and online when connected'),
            ] else ...[
              const Text(
                'This will permanently delete the note.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (isOffline) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).deleteNote(note['uuid']);
              },
              child: const Text('Delete Locally'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNoteWhenOnline(context, note);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete When Online'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).deleteNote(note['uuid']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ],
      ),
    );
  }

  /// Delete note when online (mark for deletion)
  void _deleteNoteWhenOnline(
      BuildContext context, Map<String, dynamic> note) async {
    try {
      // Mark note for deletion when online
      final storage = ref.read(unifiedStorageServiceProvider);
      final noteObj = await storage.getNoteByUuid(note['uuid']);

      if (noteObj != null) {
        noteObj.delete();
        await storage.updateNote(noteObj);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Note "${note['title']}" will be deleted when online'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark note for deletion: $e')),
      );
    }
  }

  /// Sync notebook
  void _syncNotebook(
      BuildContext context, Map<String, dynamic> notebook) async {
    final syncService = ref.read(unifiedSyncServiceProvider);
    try {
      await syncService.syncSingleNotebook(notebook['uuid']);
      await ref.read(notebooksProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notebook synchronized online!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  /// Show share note dialog
  void _showShareNoteDialog(BuildContext context, Map<String, dynamic> note) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => ShareNoteDialog(
        noteId: note['uuid'] ?? '',
        noteTitle: note['title'] ?? 'Untitled',
      ),
    );
  }
}

/// Dialog for creating a new note
class CreateNoteDialog extends ConsumerStatefulWidget {
  const CreateNoteDialog({super.key});

  @override
  ConsumerState<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends ConsumerState<CreateNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedNotebookUuid;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notebooksAsync = ref.watch(notebooksProvider);
    final formNotifier = ref.read(createNoteFormProvider.notifier);

    return AlertDialog(
      title: const Text('Create Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(createNoteFormProvider.notifier).setTitle(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(createNoteFormProvider.notifier).setContent(value);
              },
            ),
            const SizedBox(height: 16),
            // Notebook selection dropdown
            if (notebooksAsync.hasValue)
              DropdownButtonFormField<String>(
                value: _selectedNotebookUuid,
                decoration: const InputDecoration(
                  labelText: 'Notebook',
                  border: OutlineInputBorder(),
                ),
                items: notebooksAsync.value!.map((notebook) {
                  return DropdownMenuItem<String>(
                    value: notebook['id'] as String,
                    child: Text(notebook['name'] as String? ?? 'Untitled'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedNotebookUuid = value;
                  });
                  ref
                      .read(createNoteFormProvider.notifier)
                      .setNotebookUuid(value ?? '');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a notebook';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: formNotifier.isValid ? () => _createNote(context) : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  /// Create the note
  void _createNote(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(notesProvider.notifier).createNote(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              notebookUuid: _selectedNotebookUuid!,
            );

        ref.read(createNoteFormProvider.notifier).reset();

        if (!context.mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    }
  }
}

/// Dialog for creating a new notebook
class CreateNotebookDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? notebookToEdit;

  const CreateNotebookDialog({
    super.key,
    this.notebookToEdit,
  });

  @override
  ConsumerState<CreateNotebookDialog> createState() =>
      _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends ConsumerState<CreateNotebookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#2196F3';

  @override
  void initState() {
    super.initState();

    // If editing a notebook, populate fields with existing data
    if (widget.notebookToEdit != null) {
      _nameController.text = widget.notebookToEdit!['name'] ?? '';
      _descriptionController.text = widget.notebookToEdit!['description'] ?? '';

      // Validate color exists in dropdown options
      final notebookColor = widget.notebookToEdit!['color'] ?? '#2196F3';
      final availableColors = [
        '#2196F3',
        '#4CAF50',
        '#FF9800',
        '#E91E63',
        '#9C27B0',
        '#274472', // Add the problematic color
        '#F44336', // Red
        '#FF5722', // Deep Orange
        '#795548', // Brown
        '#607D8B', // Blue Grey
      ];
      _selectedColor =
          availableColors.contains(notebookColor) ? notebookColor : '#2196F3';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formNotifier = ref.read(notebookFormProvider.notifier);

    return AlertDialog(
      title: Text(
          widget.notebookToEdit != null ? 'Edit Notebook' : 'Create Notebook'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onChanged: (value) {
                ref.read(notebookFormProvider.notifier).setName(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                ref
                    .read(notebookFormProvider.notifier)
                    .setDescription(value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: 16),
            // Color picker
            DropdownButtonFormField<String>(
              value: _selectedColor,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '#2196F3', child: Text('Blue')),
                DropdownMenuItem(value: '#4CAF50', child: Text('Green')),
                DropdownMenuItem(value: '#FF9800', child: Text('Orange')),
                DropdownMenuItem(value: '#E91E63', child: Text('Pink')),
                DropdownMenuItem(value: '#9C27B0', child: Text('Purple')),
                DropdownMenuItem(value: '#274472', child: Text('Dark Blue')),
                DropdownMenuItem(value: '#F44336', child: Text('Red')),
                DropdownMenuItem(value: '#FF5722', child: Text('Deep Orange')),
                DropdownMenuItem(value: '#795548', child: Text('Brown')),
                DropdownMenuItem(value: '#607D8B', child: Text('Blue Grey')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedColor = value!;
                });
                ref.read(notebookFormProvider.notifier).setColor(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              formNotifier.isValid ? () => _createNotebook(context) : null,
          child: Text(widget.notebookToEdit != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  /// Create or update the notebook
  void _createNotebook(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.notebookToEdit != null) {
          // Update existing notebook
          await ref.read(notebooksProvider.notifier).updateNotebook(
            widget.notebookToEdit!['id'],
            {
              'name': _nameController.text.trim(),
              'description': _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              'color': _selectedColor,
            },
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notebook updated successfully')),
          );
        } else {
          // Create new notebook
          await ref.read(notebooksProvider.notifier).createNotebook(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                color: _selectedColor,
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notebook created successfully')),
          );
        }

        ref.read(notebookFormProvider.notifier).reset();
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save notebook: $e')),
        );
      }
    }
  }
}
