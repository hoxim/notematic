import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';

class SyncToggle extends ConsumerWidget {
  final VoidCallback? onSyncNow;

  const SyncToggle({
    super.key,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncEnabledAsync = ref.watch(syncEnabledProvider);

    return syncEnabledAsync.when(
      loading: () => const Row(
        children: [
          Text('Sync'),
          SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (error, stack) => Row(
        children: [
          const Text('Sync'),
          const SizedBox(width: 8),
          Icon(
            Icons.error,
            color: Colors.red,
            size: 16,
          ),
        ],
      ),
      data: (isSyncEnabled) => Row(
        children: [
          const Text('Sync'),
          Switch(
            value: isSyncEnabled,
            onChanged: (value) {
              ref.read(syncEnabledProvider.notifier).setSyncEnabled(value);
            },
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
      ),
    );
  }
}
