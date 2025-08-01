import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import 'create_note_screen.dart';
import '../providers/sync_service_provider.dart';

class NoteViewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> note;

  const NoteViewScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends ConsumerState<NoteViewScreen> {
  late Map<String, dynamic> _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;
    final notebookName = note['notebookName'] as String? ?? 'Unknown Notebook';
    final tags = note['tags'] as List<dynamic>? ?? [];
    final isOffline = note['isOffline'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(note['title'] ?? 'Untitled'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNote(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteNote(context);
                  break;
                case 'sync':
                  _syncNote(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (isOffline)
                const PopupMenuItem<String>(
                  value: 'sync',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload, size: 20),
                      SizedBox(width: 8),
                      Text('Synchronize online'),
                    ],
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete note', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note['title'] ?? 'Untitled',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Notebook info
            Row(
              children: [
                Icon(
                  Icons.folder,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  notebookName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud_done,
                  size: 20,
                  color: isOffline ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isOffline ? 'Offline' : 'Online',
                  style: TextStyle(
                    color: isOffline ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            if (tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Content
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.black26,
                ),
              ),
              child: Text(
                note['content'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),

            // Metadata
            if (note['createdAt'] != null || note['updatedAt'] != null) ...[
              Text(
                'Metadata',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note['createdAt'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${_formatDate(note['createdAt'])}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (note['updatedAt'] != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.update,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Updated: ${_formatDate(note['updatedAt'])}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      try {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return date;
      }
    }
    return date.toString();
  }

  void _editNote(BuildContext context) async {
    final updatedNote = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNoteScreen(
          noteToEdit: _note,
        ),
      ),
    );
    if (updatedNote != null) {
      setState(() {
        _note = updatedNote;
      });
    }
  }

  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(notesProvider.notifier).deleteNote(_note['uuid']);
              Navigator.of(context).pop();
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

  void _syncNote(BuildContext context) async {
    final syncService = ref.read(unifiedSyncServiceProvider);
    try {
      await syncService.syncSingleNote(_note['uuid']);
      // Pobierz zaktualizowaną notatkę po sync
      final updatedNote =
          await ref.read(notesProvider.notifier).getNoteByUuid(_note['uuid']);
      setState(() {
        _note = updatedNote;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note synchronized online!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }
}
