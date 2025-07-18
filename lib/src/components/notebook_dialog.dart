import 'package:flutter/material.dart';
import '../utils/note_colors.dart';

class NotebookDialog extends StatefulWidget {
  final Function(String name, String? description, String color) onCreate;

  const NotebookDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<NotebookDialog> createState() => _NotebookDialogState();
}

class _NotebookDialogState extends State<NotebookDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedColor = '#2196F3'; // Default blue

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                final hexColor = '#${color.value.toRadixString(16).substring(2)}';

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = hexColor;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: selectedColor == hexColor
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
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a notebook name'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            Navigator.of(context).pop();
            widget.onCreate(
              nameController.text.trim(),
              descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
              selectedColor,
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
