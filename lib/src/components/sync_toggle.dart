import 'package:flutter/material.dart';

class SyncToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onSyncNow;

  const SyncToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Sync'),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
        if (onSyncNow != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: onSyncNow,
            tooltip: 'Sync Now',
            iconSize: 20,
          ),
        ],
      ],
    );
  }
}
