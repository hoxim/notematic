import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'home_screen.dart'; // Dodany import dla CreateNotebookDialog

class CreateNoteScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? noteToEdit;
  const CreateNoteScreen({super.key, this.noteToEdit});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedNotebookUuid;

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!['title'] ?? '';
      _contentController.text = widget.noteToEdit!['content'] ?? '';
      _selectedNotebookUuid = widget.noteToEdit!['notebookUuid'];
    }
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteToEdit != null ? 'Edit Note' : 'Create Note'),
        actions: [
          TextButton(
            onPressed: formNotifier.isValid ? _saveNote : null,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- NOTEBOOK DROPDOWN OR ADD BUTTON ---
              if (notebooksAsync.hasValue && notebooksAsync.value!.isNotEmpty)
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
                    formNotifier.setNotebookUuid(value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a notebook';
                    }
                    return null;
                  },
                )
              else if (notebooksAsync.hasValue && notebooksAsync.value!.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No notebooks found. You need at least one notebook to create a note.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add notebook'),
                      onPressed: () async {
                        final created = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => const CreateNotebookDialog(),
                        );
                        if (created != null) {
                          // Odśwież notebooksProvider
                          await ref.read(notebooksProvider.notifier).refresh();
                          // Pobierz najnowszą listę
                          final updated = ref.read(notebooksProvider);
                          if (updated.hasValue && updated.value!.isNotEmpty) {
                            setState(() {
                              _selectedNotebookUuid =
                                  updated.value!.last['id'] as String;
                            });
                            formNotifier
                                .setNotebookUuid(_selectedNotebookUuid!);
                          }
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // --- TITLE FIELD ---
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
                  formNotifier.setTitle(value);
                },
              ),
              const SizedBox(height: 16),
              // --- CONTENT FIELD ---
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
                onChanged: (value) {
                  formNotifier.setContent(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.noteToEdit != null) {
          // Update existing note
          await ref.read(notesProvider.notifier).updateNote(
            widget.noteToEdit!['uuid'],
            {
              'title': _titleController.text.trim(),
              'content': _contentController.text.trim(),
              'notebookUuid': _selectedNotebookUuid!,
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
        } else {
          // Create new note
          await ref.read(notesProvider.notifier).createNote(
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                notebookUuid: _selectedNotebookUuid!,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note created successfully')),
          );
        }
        ref.read(createNoteFormProvider.notifier).reset();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    }
  }
}
