import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class NotebooksListView extends ConsumerWidget {
  final Function(Map<String, dynamic>) onNotebookTap;
  final Function(Map<String, dynamic>)? onEditNotebook;
  final Function(Map<String, dynamic>)? onDeleteNotebook;
  final Function(Map<String, dynamic>)? onSyncNotebook;

  const NotebooksListView({
    super.key,
    required this.onNotebookTap,
    this.onEditNotebook,
    this.onDeleteNotebook,
    this.onSyncNotebook,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooksAsync = ref.watch(notebooksProvider);
    final isLoading = ref.watch(loadingProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return notebooksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (notebooks) {
        if (notebooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notebooks yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first notebook to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: notebooks.length,
          itemBuilder: (context, index) {
            final notebook = notebooks[index];
            final isOffline = notebook['isOffline'] == true;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getNotebookColor(notebook['color']),
                      child: const Icon(Icons.folder, color: Colors.white),
                    ),
                    // Online/Offline indicator
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isOffline ? Colors.orange : Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isOffline ? Icons.cloud_off : Icons.cloud_done,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  notebook['name'] ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notebook['description'] != null &&
                        notebook['description'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          notebook['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notebook['noteCount'] ?? 0} notes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          isOffline ? Icons.cloud_off : Icons.cloud_done,
                          size: 16,
                          color: isOffline ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOffline ? 'Offline' : 'Online',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOffline ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEditNotebook?.call(notebook);
                        break;
                      case 'delete':
                        onDeleteNotebook?.call(notebook);
                        break;
                      case 'sync':
                        onSyncNotebook?.call(notebook);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit notebook'),
                        ],
                      ),
                    ),
                    if (notebook['isOffline'] == true)
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
                          Text('Delete notebook',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => onNotebookTap(notebook),
              ),
            );
          },
        );
      },
    );
  }

  Color _getNotebookColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.blue;
    }

    try {
      // Handle hex colors
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceAll('#', '0xFF')));
      }

      // Handle named colors
      switch (colorString.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          return Colors.blue;
      }
    } catch (e) {
      return Colors.blue;
    }
  }
}
