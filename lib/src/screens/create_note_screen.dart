import 'package:flutter/material.dart';
import '../services/notebook_service.dart';
import '../services/logger_service.dart';

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
  final _notebookService = NotebookService();
  final _logger = LoggerService();

  List<Map<String, dynamic>> _notebooks = [];
  String? _selectedNotebookId;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.noteTitle ?? '';
    _contentController.text = widget.noteContent ?? '';
    _selectedNotebookId = widget.notebookId;
    _loadNotebooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNotebooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notebooks = await _notebookService.getUserNotebooks();
      print('Loaded notebooks: ' + notebooks.toString()); // Debug log
      // Map notebooks so that 'id' is always present
      final mappedNotebooks =
          notebooks.map((n) {
            if (n['id'] == null && n['_id'] != null) {
              n['id'] = n['_id'];
            }
            return n;
          }).toList();
      final notebookIds =
          mappedNotebooks.map((n) => n['id'] as String?).toList();
      setState(() {
        _notebooks = mappedNotebooks;
        // Always select a valid notebook or null
        if (_selectedNotebookId == null ||
            !notebookIds.contains(_selectedNotebookId)) {
          _selectedNotebookId =
              notebookIds.isNotEmpty ? notebookIds.first : null;
        }
        _isLoading = false;
      });
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

    if (_selectedNotebookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a notebook'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _notebookService.createNote(
        notebookId: _selectedNotebookId!,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (success) {
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
      } else {
        throw Exception('Failed to save note');
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
      body:
          _isLoading
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
                                    color: Color(
                                      int.parse(
                                        ((notebook['color'] as String?) ??
                                                '#2196F3')
                                            .replaceAll('#', '0xFF'),
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                title: Text(notebook['name'] as String),
                                trailing:
                                    _selectedNotebookId == notebook['id']
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                        : null,
                                onTap: () {
                                  final id = notebook['id'];
                                  if (id != null && id is String) {
                                    setState(() {
                                      _selectedNotebookId = id;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notebook ID is missing!',
                                        ),
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
