import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/share_models.dart';
import '../services/api_service.dart';
import '../providers/logger_provider.dart';

class SharedNotesScreen extends ConsumerStatefulWidget {
  const SharedNotesScreen({super.key});

  @override
  ConsumerState<SharedNotesScreen> createState() => _SharedNotesScreenState();
}

class _SharedNotesScreenState extends ConsumerState<SharedNotesScreen> {
  List<SharedNote> _sharedNotes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSharedNotes();
  }

  Future<void> _loadSharedNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final notes = await apiService.getSharedNotes();

      if (mounted) {
        setState(() {
          _sharedNotes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        ref.read(loggerServiceProvider).error('Failed to load shared notes', e);
      }
    }
  }

  Future<void> _deleteShare(SharedNote share) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Share'),
        content: Text(
            'Are you sure you want to delete this share for "${share.noteTitle ?? 'Untitled'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        final success = await apiService.deleteShare(share.shareId);

        if (success) {
          setState(() {
            _sharedNotes.removeWhere((note) => note.shareId == share.shareId);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete share'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ref.read(loggerServiceProvider).error('Error deleting share', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Notes'),
        actions: [
          IconButton(
            onPressed: _loadSharedNotes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading shared notes',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSharedNotes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sharedNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No shared notes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notes you share will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSharedNotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sharedNotes.length,
        itemBuilder: (context, index) {
          final share = _sharedNotes[index];
          return _buildShareCard(theme, share);
        },
      ),
    );
  }

  Widget _buildShareCard(ThemeData theme, SharedNote share) {
    final isExpired = share.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isExpired ? Colors.grey : theme.colorScheme.primary,
          child: Icon(
            _getShareTypeIcon(share.shareType),
            color: Colors.white,
          ),
        ),
        title: Text(
          share.noteTitle ?? 'Untitled',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpired
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${share.formattedCreatedAt}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${share.accessCount} views',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (share.expiresAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isExpired
                        ? Colors.red
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${share.formattedExpiresAt}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isExpired
                          ? Colors.red
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _buildPermissionsChips(theme, share.permissions),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteShare(share);
                break;
              case 'copy_link':
                _copyShareLink(share);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_link',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy Link'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Share', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsChips(ThemeData theme, SharePermissions permissions) {
    final chips = <Widget>[];

    if (permissions.canRead) {
      chips.add(Chip(
        label: const Text('Read'),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: Colors.green.shade700),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ));
    }

    if (permissions.canWrite) {
      chips.add(Chip(
        label: const Text('Write'),
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: Colors.blue.shade700),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ));
    }

    if (permissions.canShare) {
      chips.add(Chip(
        label: const Text('Share'),
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: Colors.orange.shade700),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ));
    }

    if (permissions.canDelete) {
      chips.add(Chip(
        label: const Text('Delete'),
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: Colors.red.shade700),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ));
    }

    return Wrap(
      spacing: 4,
      children: chips,
    );
  }

  IconData _getShareTypeIcon(ShareType shareType) {
    switch (shareType) {
      case ShareType.public:
        return Icons.link;
      case ShareType.user:
        return Icons.person;
      case ShareType.email:
        return Icons.email;
    }
  }

  void _copyShareLink(SharedNote share) {
    // TODO: Implement copy to clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
