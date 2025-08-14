import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/share_models.dart';
import '../services/api_service.dart';
import '../providers/logger_provider.dart';

class ShareNoteDialog extends ConsumerStatefulWidget {
  final String noteId;
  final String noteTitle;

  const ShareNoteDialog({
    super.key,
    required this.noteId,
    required this.noteTitle,
  });

  @override
  ConsumerState<ShareNoteDialog> createState() => _ShareNoteDialogState();
}

class _ShareNoteDialogState extends ConsumerState<ShareNoteDialog> {
  ShareType _selectedShareType = ShareType.public;
  SharePermissions _selectedPermissions = SharePermissions.readOnly();
  String? _userEmail;
  String? _password;
  DateTime? _expiresAt;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.share, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Share Note'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sharing:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.noteTitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Share type selection
            Text(
              'Share Type:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ShareType>(
              value: _selectedShareType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ShareType.values.map((type) {
                String label;
                IconData icon;
                switch (type) {
                  case ShareType.public:
                    label = 'Public Link';
                    icon = Icons.link;
                    break;
                  case ShareType.user:
                    label = 'User';
                    icon = Icons.person;
                    break;
                  case ShareType.email:
                    label = 'Email';
                    icon = Icons.email;
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedShareType = value;
                    _userEmail = null;
                    _password = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // User email input (for user/email sharing)
            if (_selectedShareType == ShareType.user ||
                _selectedShareType == ShareType.email) ...[
              Text(
                'User Email:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter user email',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _userEmail = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Password input (for public sharing)
            if (_selectedShareType == ShareType.public) ...[
              Text(
                'Password (optional):',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password for link',
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value.isEmpty ? null : value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Permissions selection
            Text(
              'Permissions:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPermissionsSelector(theme),
            const SizedBox(height: 16),

            // Expiration date
            Text(
              'Expires (optional):',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select expiration date',
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _expiresAt?.toIso8601String().split('T')[0] ?? '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _expiresAt = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _expiresAt = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear expiration',
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _shareNote,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Share'),
        ),
      ],
    );
  }

  Widget _buildPermissionsSelector(ThemeData theme) {
    return Column(
      children: [
        RadioListTile<SharePermissions>(
          title: const Text('Read Only'),
          subtitle: const Text('Can only view the note'),
          value: SharePermissions.readOnly(),
          groupValue: _selectedPermissions,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPermissions = value;
              });
            }
          },
        ),
        RadioListTile<SharePermissions>(
          title: const Text('Read & Write'),
          subtitle: const Text('Can view and edit the note'),
          value: SharePermissions.readWrite(),
          groupValue: _selectedPermissions,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPermissions = value;
              });
            }
          },
        ),
        RadioListTile<SharePermissions>(
          title: const Text('Full Access'),
          subtitle: const Text('Can view, edit, share, and delete'),
          value: SharePermissions.full(),
          groupValue: _selectedPermissions,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPermissions = value;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _shareNote() async {
    // Validate input
    if ((_selectedShareType == ShareType.user ||
            _selectedShareType == ShareType.email) &&
        (_userEmail == null || _userEmail!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a user email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final shareRequest = ShareRequest(
        noteId: widget.noteId,
        shareType: _selectedShareType,
        permissions: _selectedPermissions,
        expiresAt: _expiresAt,
        password: _password,
        userEmail: _userEmail,
      );

      final response = await apiService.shareNote(widget.noteId, shareRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response != null) {
          Navigator.of(context).pop(response);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share note'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ref.read(loggerServiceProvider).error('Error sharing note', e);
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
