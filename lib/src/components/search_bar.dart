import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ui_provider.dart';

class NotesSearchBar extends ConsumerWidget {
  final TextEditingController controller;

  const NotesSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          onChanged: (value) {
            ref.read(searchProvider.notifier).setQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Search notes...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
