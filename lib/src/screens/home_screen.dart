import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/notebooks_provider.dart';
import '../providers/user_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/form_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/logger_provider.dart';
import '../providers/token_provider.dart';
import '../providers/storage_provider.dart';
import '../providers/simple_local_storage_provider.dart';
import '../components/notes_list_view.dart';
import '../components/notebooks_list_view.dart';
import '../components/search_bar.dart';
import '../components/search_results_list.dart';
import '../components/user_profile_menu.dart';
import '../components/create_fab.dart';
import '../components/sync_toggle.dart';
import 'note_view_screen.dart';
import '../services/unified_sync_service.dart';
import 'create_note_screen.dart';
import '../providers/sync_service_provider.dart';

/// Home screen that displays notes and notebooks
/// Uses unified models and providers for state management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showNotebooks = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

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
      await syncService.initialize();
    } catch (e) {
      // Handle initialization error
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final notebooksAsync = ref.watch(notebooksProvider);
    final syncEnabledAsync = ref.watch(syncEnabledProvider);
    final searchState = ref.watch(searchProvider);
    final fabExpanded = ref.watch(fabExpandedProvider);
    final userState = ref.watch(userProvider);

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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync completed successfully')),
                );
              } catch (e) {
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
            onAboutTap: () {
              // Handle about tap
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
              : NotesListView(
                  onNoteTap: (note) {
                    // Navigate to note view screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteViewScreen(note: note),
                      ),
                    );
                  },
                  onDeleteNote: (note) {
                    // Handle note delete
                    ref.read(notesProvider.notifier).deleteNote(note['uuid']);
                  },
                  onSyncNote: (note) async {
                    final syncService = ref.read(unifiedSyncServiceProvider);
                    try {
                      await syncService.syncSingleNote(note['uuid']);
                      await ref.read(notesProvider.notifier).refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Note synchronized online!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sync failed: $e')),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
    );
  }

  /// Show create notebook dialog
  void _showCreateNotebookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateNotebookDialog(),
    );
  }

  /// Show edit notebook dialog
  void _showEditNotebookDialog(
      BuildContext context, Map<String, dynamic> notebook) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notebook'),
        content: Text(
            'Are you sure you want to delete "${notebook['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
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
      ),
    );
  }

  /// Sync notebook
  void _syncNotebook(BuildContext context, Map<String, dynamic> notebook) {
    // TODO: Implement notebook sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notebook sync functionality coming soon')),
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
    final formState = ref.watch(createNoteFormProvider);
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
          onPressed: formNotifier.isValid ? _createNote : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  /// Create the note
  void _createNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(notesProvider.notifier).createNote(
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              notebookUuid: _selectedNotebookUuid!,
            );

        ref.read(createNoteFormProvider.notifier).reset();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
      } catch (e) {
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
    final formState = ref.watch(notebookFormProvider);
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
          onPressed: formNotifier.isValid ? _createNotebook : null,
          child: Text(widget.notebookToEdit != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  /// Create or update the notebook
  void _createNotebook() async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notebook created successfully')),
          );
        }

        ref.read(notebookFormProvider.notifier).reset();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save notebook: $e')),
        );
      }
    }
  }
}
