import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNoteScreen extends StatefulWidget {
  final String? notebookId;
  final String? noteTitle;
  final String? noteContent;

  const CreateNoteScreen({
    super.key,
    this.notebookId,
    this.noteTitle,
    this.noteContent,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _logger = LoggerService();

  List<dynamic> _notebooks = [];
  String? _selectedNotebookId;
  bool _isLoading = false;
  bool _isSaving = false;
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.noteTitle ?? '';
    _contentController.text = widget.noteContent ?? '';
    _selectedNotebookId = widget.notebookId;
    _notebooks = [];
    _initServices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    _loadNotebooks();
  }

  /// Check if sync is enabled and API is available
  Future<bool> _isOfflineMode() async {
    try {
      // Check if sync is disabled
      final prefs = await SharedPreferences.getInstance();
      final isSyncEnabled = prefs.getBool('isSyncEnabled') ?? true;

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

  Future<void> _loadNotebooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use SyncService to get all notebooks (online + offline)
      final syncService = SyncService();
      final notebooks = await syncService.getAllNotebooks();
      _logger.info('Loaded notebooks: $notebooks');

      if (notebooks.isEmpty) {
        _logger.info('No notebooks found, creating default notebook');
        await syncService.createNotebook(
          name: 'Default',
          description: 'Default notebook for notes',
          color: '#9C27B0',
        );
        _logger.info('Default notebook created');

        // Reload notebooks after creation
        final updatedNotebooks = await syncService.getAllNotebooks();
        setState(() {
          _notebooks = updatedNotebooks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notebooks = notebooks;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.error('Failed to load notebooks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // If no notebook is selected, create a default "Untitled" one
    if (_selectedNotebookId == null) {
      setState(() {
        _isSaving = true;
      });

      try {
        _logger.info(
          'No notebook selected, creating default "Untitled" notebook',
        );

        // Use SyncService to create notebook
        final syncService = SyncService();
        await syncService.createNotebook(
          name: 'Untitled',
          description: 'Default notebook for notes',
          color: '#9C27B0',
        );

        // Get the created notebook and set it as selected
        final notebooks = await syncService.getAllNotebooks();
        _logger.info('Retrieved notebooks after creation: $notebooks');

        if (notebooks.isNotEmpty) {
          // Find "Untitled" notebook or take the first one
          final untitledNotebook = notebooks.firstWhere(
            (notebook) => notebook.name == 'Untitled',
            orElse: () => notebooks.first,
          );
          _logger.info('Selected notebook: $untitledNotebook');

          _selectedNotebookId = untitledNotebook.uuid;
          _logger.info(
              'Default notebook created and selected: ${untitledNotebook.uuid}');
        } else {
          _logger.error('No notebooks found after creation');
          throw Exception(
            'Failed to create default notebook - no notebooks returned',
          );
        }
      } catch (e) {
        _logger.error('Failed to create default notebook: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create default notebook: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Use SyncService to create note (handles both online and offline)
      final syncService = SyncService();

      await syncService.createNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        notebookUuid: _selectedNotebookId!,
      );

      _logger.info('Note created successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      _logger.error('Failed to save note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: _tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                ),
              )
              .toList(),
        ),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            labelText: 'Add tag',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final tag = _tagController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                  _tagController.clear();
                }
              },
            ),
          ),
          onSubmitted: (tag) {
            tag = tag.trim();
            if (tag.isNotEmpty && !_tags.contains(tag)) {
              setState(() {
                _tags.add(tag);
              });
              _tagController.clear();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteTitle == null ? 'New Note' : 'Edit Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _saveNote, child: const Text('Save'))
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notebook selector
                    if (_notebooks.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'You have no notebooks. Please create one first.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement notebook creation dialog or navigation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Create notebook feature coming soon!',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Notebook'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Select notebook:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120, // Adjust height as needed
                        child: ListView.builder(
                          itemCount: _notebooks.length,
                          itemBuilder: (context, index) {
                            final notebook = _notebooks[index];
                            return ListTile(
                              leading: Stack(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: (() {
                                        final colorValue = notebook.color;
                                        if (colorValue != null &&
                                            colorValue.isNotEmpty) {
                                          try {
                                            return Color(
                                              int.parse(
                                                colorValue.replaceAll(
                                                    '#', '0xFF'),
                                              ),
                                            );
                                          } catch (_) {
                                            return const Color(0xFF2196F3);
                                          }
                                        }
                                        return const Color(0xFF2196F3);
                                      })(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  // Offline indicator for notebooks
                                  if (notebook.isOffline)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notebook.name ?? 'Untitled',
                                    ),
                                  ),
                                  if (notebook.isOffline)
                                    const Icon(
                                      Icons.cloud_off,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                              trailing: _selectedNotebookId == notebook.uuid
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedNotebookId = notebook.uuid;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTagInput(),
                    const SizedBox(height: 16),
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        hintText: 'Enter note title...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Content field
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                          hintText: 'Start writing your note...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter some content';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
