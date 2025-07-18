import 'package:flutter/material.dart';

class CreateFAB extends StatelessWidget {
  final bool isExpanded;
  final Animation<double> animation;
  final VoidCallback onCreateNote;
  final VoidCallback onCreateNotebook;
  final VoidCallback onToggle;

  const CreateFAB({
    super.key,
    required this.isExpanded,
    required this.animation,
    required this.onCreateNote,
    required this.onCreateNotebook,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ScaleTransition(
              scale: animation,
              child: FloatingActionButton.extended(
                onPressed: onCreateNotebook,
                heroTag: 'createNotebook',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                icon: const Icon(Icons.book),
                label: const Text('Notebook'),
              ),
            ),
          ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ScaleTransition(
              scale: animation,
              child: FloatingActionButton.extended(
                onPressed: onCreateNote,
                heroTag: 'createNote',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: const Icon(Icons.note_add),
                label: const Text('Note'),
              ),
            ),
          ),
        FloatingActionButton(
          onPressed: onToggle,
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
