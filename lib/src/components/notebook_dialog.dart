import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/note_colors.dart';
import '../providers/providers.dart';

class NotebookDialog extends ConsumerStatefulWidget {
  final Function(String name, String? description, String color) onCreate;

  const NotebookDialog({
    super.key,
    required this.onCreate,
  });

  @override
  ConsumerState<NotebookDialog> createState() => _NotebookDialogState();
}

class _NotebookDialogState extends ConsumerState<NotebookDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with default color
    ref.read(notebookFormProvider.notifier).setColor('#2196F3');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(notebookFormProvider);

    return AlertDialog(
      title: const Text('Create New Notebook'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Notebook Name',
                border: OutlineInputBorder(),
                hintText: 'Enter notebook name...',
              ),
              autofocus: true,
              onChanged: (value) {
                ref.read(notebookFormProvider.notifier).setName(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter description...',
              ),
              maxLines: 2,
              onChanged: (value) {
                ref.read(notebookFormProvider.notifier).setDescription(value);
              },
            ),
            const SizedBox(height: 16),
            const Text('Choose color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: noteColors.asMap().entries.map((entry) {
                final index = entry.key;
                final colors = entry.value;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final color = getNotebookColor(index, isDark);
                final hexColor =
                    '#${color.value.toRadixString(16).substring(2)}';

                return GestureDetector(
                  onTap: () {
                    ref.read(notebookFormProvider.notifier).setColor(hexColor);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: formState.color == hexColor
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }).toList(),
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
          onPressed: ref.read(notebookFormProvider.notifier).isValid
              ? () {
                  Navigator.of(context).pop();
                  widget.onCreate(
                    formState.name,
                    formState.description?.isEmpty == true
                        ? null
                        : formState.description,
                    formState.color ?? '#2196F3',
                  );
                }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
