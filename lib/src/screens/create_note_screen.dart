import 'package:flutter/material.dart';
import '../services/note_service_factory.dart';
import '../services/notebook_service_factory.dart';
import '../models/note.dart';
import '../models/notebook.dart';
import '../services/logger_service.dart';
import '../services/interfaces/note_service_interface.dart';
import '../services/interfaces/notebook_service_interface.dart';

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
  late final INotebookService<Notebook> _notebookService;
  final _logger = LoggerService();
  late final INoteService<Note> _noteService;

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
    _noteService = await getNoteService();
    _notebookService = await getNotebookService();
    _loadNotebooks();
  }

  Future<void> _loadNotebooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notebooks = await _notebookService.getUserNotebooks();
      _logger.info('Loaded notebooks: $notebooks');

      // API zwraca {notebooks: []} zamiast bezpośrednio listy
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

      // Jeśli nie ma żadnych notebooków, utwórz domyślny
      if (mappedNotebooks.isEmpty) {
        _logger.info('No notebooks found, creating default notebook');
        await _notebookService.createNotebook('Default');
        _logger.info('Default notebook created');
        // Możesz dodać dodatkowe akcje, np. odświeżenie listy
      } else {
        setState(() {
          _notebooks = mappedNotebooks;
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

    // Jeśli nie ma wybranego notebooka, utwórz domyślny "Untitled"
    if (_selectedNotebookId == null) {
      setState(() {
        _isSaving = true;
      });

      try {
        _logger.info(
          'No notebook selected, creating default "Untitled" notebook',
        );
        await _notebookService.createNotebook(
          'Untitled',
          description: 'Default notebook for notes',
          color: '#9C27B0',
        );

        // Pobierz utworzony notebook i ustaw go jako wybrany
        final notebooks = await _notebookService.getUserNotebooks();
        _logger.info('Retrieved notebooks after creation: $notebooks');
        _logger.info('Notebooks type: ${notebooks.runtimeType}');
        _logger.info('Notebooks length: ${notebooks.length}');

        // Parsuj strukturę danych z API
        List<dynamic> mappedNotebooks = [];
        if (notebooks.isNotEmpty && notebooks.first is Map) {
          final firstItem = notebooks.first as Map;
          _logger.info('First item keys: ${firstItem.keys.toList()}');
          if (firstItem.containsKey('notebooks')) {
            mappedNotebooks = (firstItem['notebooks'] as List?) ?? [];
            _logger.info(
              'Extracted notebooks from firstItem: $mappedNotebooks',
            );
          } else {
            mappedNotebooks = notebooks;
            _logger.info('Using notebooks directly: $mappedNotebooks');
          }
        } else {
          mappedNotebooks = notebooks;
          _logger.info('Using notebooks directly (not Map): $mappedNotebooks');
        }

        _logger.info('Final mappedNotebooks length: ${mappedNotebooks.length}');

        if (mappedNotebooks.isNotEmpty) {
          // Znajdź notebook "Untitled" lub weź pierwszy
          final untitledNotebook = mappedNotebooks.firstWhere(
            (notebook) => (notebook['name'] as String?) == 'Untitled',
            orElse: () => mappedNotebooks.first,
          );
          _logger.info('Selected notebook: $untitledNotebook');

          // Sprawdź różne możliwe pola ID
          final notebookId =
              untitledNotebook['id'] ??
              untitledNotebook['_id'] ??
              untitledNotebook['notebook_id'];
          _logger.info('Notebook ID found: $notebookId');

          if (notebookId != null && notebookId is String) {
            _selectedNotebookId = notebookId;
            _logger.info('Default notebook created and selected: $notebookId');
          } else {
            _logger.error('Notebook structure: $untitledNotebook');
            throw Exception(
              'Failed to get notebook ID - ID is null or not a string',
            );
          }
        } else {
          _logger.error('No notebooks found in mappedNotebooks');
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
      final note = Note(
        id: UniqueKey().toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        updatedAt: DateTime.now(),
        notebookUuid: _selectedNotebookId!,
      );
      await _noteService.upsertNote(note);

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
                              leading: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: (() {
                                    final colorValue = notebook['color'];
                                    if (colorValue is String &&
                                        colorValue.isNotEmpty) {
                                      try {
                                        return Color(
                                          int.parse(
                                            colorValue.replaceAll('#', '0xFF'),
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
                              title: Text(
                                (notebook['name'] as String?) ?? 'Untitled',
                              ),
                              trailing:
                                  _selectedNotebookId ==
                                      (notebook['id'] ?? notebook['_id'])
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                final id = notebook['id'] ?? notebook['_id'];
                                if (id != null && id is String) {
                                  setState(() {
                                    _selectedNotebookId = id;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Notebook ID is missing!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
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
