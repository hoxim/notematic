import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/notebooks_provider.dart';

class NoteEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? noteToEdit;

  const NoteEditScreen({super.key, this.noteToEdit});

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  String? _selectedNotebookUuid;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!['title'] ?? '';
      _contentController.text = widget.noteToEdit!['content'] ?? '';
      _selectedNotebookUuid = widget.noteToEdit!['notebookUuid'];
    }

    // Listen for changes
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set default notebook when creating new note
    if (widget.noteToEdit == null && _selectedNotebookUuid == null) {
      final notebooksAsync = ref.read(notebooksProvider);
      if (notebooksAsync.hasValue && notebooksAsync.value!.isNotEmpty) {
        setState(() {
          _selectedNotebookUuid = notebooksAsync.value!.first['uuid'] as String;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notebooksAsync = ref.watch(notebooksProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // Top toolbar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onBackPressed(),
          ),
          actions: [
            // Simple formatting buttons
            IconButton(
              icon: const Icon(Icons.format_bold),
              onPressed: () => _toggleBold(),
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              onPressed: () => _toggleItalic(),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(),
            ),
          ],
        ),

        body: Column(
          children: [
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Notebook selection (only show when creating new note)
                    if (widget.noteToEdit == null &&
                        notebooksAsync.hasValue &&
                        notebooksAsync.value!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _selectedNotebookUuid ??
                              notebooksAsync.value!.first['uuid'],
                          decoration: const InputDecoration(
                            labelText: 'Notebook',
                            border: OutlineInputBorder(),
                          ),
                          items: notebooksAsync.value!.map((notebook) {
                            return DropdownMenuItem<String>(
                              value: notebook['uuid'] as String,
                              child: Text(
                                  notebook['name'] as String? ?? 'Untitled'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedNotebookUuid = value;
                              });
                            }
                          },
                        ),
                      ),

                    // Title field - no border, no background, larger font
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    ),

                    // Formatting toolbar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold, size: 20),
                            onPressed: () => _toggleBold(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic, size: 20),
                            onPressed: () => _toggleItalic(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_underline, size: 20),
                            onPressed: () => _toggleUnderline(),
                          ),
                        ],
                      ),
                    ),

                    // Content field - no border, takes remaining space
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Date info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.noteToEdit != null) ...[
                          Text(
                            'Edited ${_formatDate(widget.noteToEdit!['updatedAt'] ?? widget.noteToEdit!['createdAt'])}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                          ),
                        ] else ...[
                          Text(
                            'Created ${_formatDate(DateTime.now().toIso8601String())}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBackPressed() {
    if (_hasChanges) {
      _showSaveDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Changes?'),
        content: const Text('Do you want to save your changes?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveNote();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save'),
              onTap: () {
                Navigator.of(context).pop();
                _saveNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteNote();
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

  void _toggleBold() {
    _formatSelectedText('**', '**');
  }

  void _toggleItalic() {
    _formatSelectedText('*', '*');
  }

  void _toggleUnderline() {
    _formatSelectedText('__', '__');
  }

  void _formatSelectedText(String startMarker, String endMarker) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (!selection.isValid || selection.start == selection.end) {
      // No selection - show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select text to format')),
      );
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selectedText = text.substring(start, end);

    // Check if the selected text is already formatted
    final isAlreadyFormatted = selectedText.startsWith(startMarker) &&
        selectedText.endsWith(endMarker) &&
        selectedText.length > (startMarker.length + endMarker.length);

    String newText;
    int newCursorPosition;

    if (isAlreadyFormatted) {
      // Remove formatting
      newText = selectedText.substring(
          startMarker.length, selectedText.length - endMarker.length);
      final before = text.substring(0, start);
      final after = text.substring(end);
      _contentController.text = before + newText + after;
      newCursorPosition = start + newText.length;
    } else {
      // Add formatting
      newText = startMarker + selectedText + endMarker;
      final before = text.substring(0, start);
      final after = text.substring(end);
      _contentController.text = before + newText + after;
      newCursorPosition = start + newText.length;
    }

    // Set cursor position
    _contentController.selection =
        TextSelection.collapsed(offset: newCursorPosition);

    setState(() {
      _hasChanges = true;
    });
  }

  Future<void> _saveNote() async {
    try {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title cannot be empty')),
        );
        return;
      }

      // Get content (formatting markers are already in the text)
      final content = _contentController.text;

      if (widget.noteToEdit != null) {
        // Update existing note
        await ref.read(notesProvider.notifier).updateNote(
          widget.noteToEdit!['uuid'],
          {
            'title': title,
            'content': content,
            'notebookUuid': _selectedNotebookUuid,
          },
        );
      } else {
        // Create new note
        await ref.read(notesProvider.notifier).createNote(
              title: title,
              content: content,
              notebookUuid: _selectedNotebookUuid ?? '',
            );
      }

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    }
  }

  Future<void> _deleteNote() async {
    if (widget.noteToEdit == null) {
      Navigator.of(context).pop();
      return;
    }

    try {
      await ref
          .read(notesProvider.notifier)
          .deleteNote(widget.noteToEdit!['uuid']);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting note: $e')),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
