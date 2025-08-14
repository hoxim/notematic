import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/notes_provider.dart';
import '../providers/ui_provider.dart';

class NotesSectionedView extends ConsumerWidget {
  final Function(Map<String, dynamic>) onNoteTap;
  final Function(Map<String, dynamic>)? onDeleteNote;
  final Function(Map<String, dynamic>)? onSyncNote;
  final Function(Map<String, dynamic>)? onShareNote;

  const NotesSectionedView({
    super.key,
    required this.onNoteTap,
    this.onDeleteNote,
    this.onSyncNote,
    this.onShareNote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final isLoading = ref.watch(loadingProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notes yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first note to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          );
        }

        // Group notes by notebook
        final Map<String, List<Map<String, dynamic>>> groupedNotes = {};
        for (final note in notes) {
          final notebookName =
              note['notebookName'] as String? ?? 'Unknown Notebook';
          groupedNotes.putIfAbsent(notebookName, () => []).add(note);
        }

        // Sort notebooks by name
        final sortedNotebooks = groupedNotes.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedNotebooks.length,
          itemBuilder: (context, index) {
            final notebookName = sortedNotebooks[index];
            final notebookNotes = groupedNotes[notebookName]!;

            return _buildNotebookSection(context, notebookName, notebookNotes);
          },
        );
      },
    );
  }

  Widget _buildNotebookSection(
    BuildContext context,
    String notebookName,
    List<Map<String, dynamic>> notes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notebook header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                notebookName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${notes.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notes grid for this notebook - automatic column adjustment
        Builder(
          builder: (context) {
            const double cardMaxWidth = 340.0;
            const double spacing = 8.0;

            // Calculate exact number of columns
            final screenWidth = MediaQuery.of(context).size.width;
            final availableWidth = screenWidth - 32;
            final columnWidth = cardMaxWidth + spacing;
            int crossAxisCount = (availableWidth / columnWidth).floor();

            // Minimum 1 column
            if (crossAxisCount < 1) crossAxisCount = 1;

            return MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildNoteCard(context, note);
              },
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    final title = note['title'] ?? 'Untitled';
    final content = note['content'] as String? ?? '';
    final createdAt = note['createdAt'] as String?;
    final tags = note['tags'] as List<dynamic>? ?? [];
    final isOffline = note['isOffline'] == true;

    // Format date
    String formattedDate = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day} ${_getMonthName(date.month)}';
      } catch (e) {
        formattedDate = 'Unknown';
      }
    }

    return Container(
      margin: EdgeInsets.zero, // Ensure no margins
      child: InkWell(
        onTap: () => onNoteTap(note),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'share':
                            onShareNote?.call(note);
                            break;
                          case 'delete':
                            onDeleteNote?.call(note);
                            break;
                          case 'sync':
                            onSyncNote?.call(note);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, size: 20),
                              SizedBox(width: 8),
                              Text('Share note'),
                            ],
                          ),
                        ),
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
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Content preview
                if (content.isNotEmpty)
                  Text(
                    content.length > 500
                        ? '${content.substring(0, 500)}...'
                        : content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                    maxLines: 25,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Footer with date and sync status
                Row(
                  children: [
                    // Sync status indicators
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Local device indicator (always active for local notes)
                        Icon(
                          Icons.phone_android,
                          size: 14,
                          color: Colors.blue.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        // Online indicator
                        Icon(
                          isOffline ? Icons.cloud_off : Icons.cloud_done,
                          size: 14,
                          color: isOffline
                              ? Colors.grey.withValues(alpha: 0.6)
                              : Colors.green,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Date
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                // Tags (if any)
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildTagList(context, tags),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagList(BuildContext context, List<dynamic> tags) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
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
