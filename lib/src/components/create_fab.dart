import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ui_provider.dart';

class CreateFAB extends ConsumerWidget {
  final Animation<double> animation;
  final VoidCallback onCreateNote;
  final VoidCallback onCreateNotebook;
  final VoidCallback onToggle;

  const CreateFAB({
    super.key,
    required this.animation,
    required this.onCreateNote,
    required this.onCreateNotebook,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(fabExpandedProvider);
    print('CreateFAB build, isExpanded: $isExpanded');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isExpanded)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ScaleTransition(
                    scale: animation,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        print('Create notebook pressed!');
                        ref.read(fabExpandedProvider.notifier).toggle();
                        onCreateNotebook();
                      },
                      heroTag: 'createNotebook',
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      icon: const Icon(Icons.book),
                      label: const Text('Notebook'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ScaleTransition(
                    scale: animation,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        print('Create note pressed!');
                        ref.read(fabExpandedProvider.notifier).toggle();
                        onCreateNote();
                      },
                      heroTag: 'createNote',
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      icon: const Icon(Icons.note_add),
                      label: const Text('Note'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        FloatingActionButton(
          onPressed: () {
            print('FAB pressed! isExpanded: $isExpanded');
            ref.read(fabExpandedProvider.notifier).toggle();
            onToggle();
          },
          heroTag: 'mainFab',
          child: AnimatedRotation(
            turns: isExpanded ? 0.125 : 0, // 45 degrees
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
