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
import 'home_screen.dart'; // Dodany import dla CreateNotebookDialog
import 'note_view_screen.dart'; // Dodany import dla NoteViewScreen

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
      // Inicjalizacja formProvidera, żeby Save był aktywny
      Future.microtask(() {
        final formNotifier = ref.read(createNoteFormProvider.notifier);
        formNotifier.setTitle(_titleController.text);
        formNotifier.setContent(_contentController.text);
        if (_selectedNotebookUuid != null) {
          formNotifier.setNotebookUuid(_selectedNotebookUuid!);
        }
      });
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
    final formState = ref.watch(createNoteFormProvider);
    final formNotifier = ref.read(createNoteFormProvider.notifier);

    // Ustaw domyślny notebook jeśli nie jest ustawiony i lista nie jest pusta
    if (notebooksAsync.hasValue &&
        notebooksAsync.value!.isNotEmpty &&
        _selectedNotebookUuid == null) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _selectedNotebookUuid =
                notebooksAsync.value!.first['uuid'] as String;
          });
          formNotifier.setNotebookUuid(_selectedNotebookUuid!);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteToEdit != null ? 'Edit Note' : 'Create Note'),
        actions: [
          TextButton(
            onPressed: formState.isValid ? _saveNote : null,
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
                      value: notebook['uuid'] as String,
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
                                  updated.value!.last['uuid'] as String;
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
          // Pobierz zaktualizowaną notatkę po uuid
          final updatedNote = await ref
              .read(notesProvider.notifier)
              .getNoteByUuid(widget.noteToEdit!['uuid']);
          ref.read(createNoteFormProvider.notifier).reset();
          // Przejdź do NoteViewScreen z nowymi danymi
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => NoteViewScreen(note: updatedNote),
              ),
            );
          }
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
          ref.read(createNoteFormProvider.notifier).reset();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note created successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    }
  }
}
