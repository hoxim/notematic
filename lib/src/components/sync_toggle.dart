import 'package:flutter/material.dart';

class SyncToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SyncToggle({
    super.key,
    required this.value,
    required this.onChanged,
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
      ],
    );
  }
}
