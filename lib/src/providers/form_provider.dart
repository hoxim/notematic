import 'package:flutter_riverpod/flutter_riverpod.dart';

final createNoteFormProvider =
    StateNotifierProvider<CreateNoteFormNotifier, CreateNoteFormState>((ref) {
  return CreateNoteFormNotifier();
});

class CreateNoteFormNotifier extends StateNotifier<CreateNoteFormState> {
  CreateNoteFormNotifier() : super(const CreateNoteFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void setNotebookUuid(String notebookUuid) {
    state = state.copyWith(notebookUuid: notebookUuid);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void setColor(String? color) {
    state = state.copyWith(color: color);
  }

  void setPriority(int? priority) {
    state = state.copyWith(priority: priority);
  }

  void reset() {
    state = const CreateNoteFormState();
  }

  bool get isValid =>
      state.title.isNotEmpty &&
      state.content.isNotEmpty &&
      state.notebookUuid.isNotEmpty;
}

class CreateNoteFormState {
  final String title;
  final String content;
  final String notebookUuid;
  final List<String> tags;
  final String? color;
  final int? priority;

  const CreateNoteFormState({
    this.title = '',
    this.content = '',
    this.notebookUuid = '',
    this.tags = const [],
    this.color,
    this.priority,
  });

  // Getter sprawdzający poprawność formularza
  bool get isValid =>
      title.trim().isNotEmpty &&
      content.trim().isNotEmpty &&
      notebookUuid.trim().isNotEmpty;

  CreateNoteFormState copyWith({
    String? title,
    String? content,
    String? notebookUuid,
    List<String>? tags,
    String? color,
    int? priority,
  }) {
    return CreateNoteFormState(
      title: title ?? this.title,
      content: content ?? this.content,
      notebookUuid: notebookUuid ?? this.notebookUuid,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }
}

final notebookFormProvider =
    StateNotifierProvider<NotebookFormNotifier, NotebookFormState>((ref) {
  return NotebookFormNotifier();
});

class NotebookFormNotifier extends StateNotifier<NotebookFormState> {
  NotebookFormNotifier() : super(const NotebookFormState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String? description) {
    state = state.copyWith(description: description);
  }

  void setColor(String? color) {
    state = state.copyWith(color: color);
  }

  void setIsDefault(bool isDefault) {
    state = state.copyWith(isDefault: isDefault);
  }

  void setSortOrder(int? sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void reset() {
    state = const NotebookFormState();
  }

  bool get isValid => state.name.isNotEmpty;
}

class NotebookFormState {
  final String name;
  final String? description;
  final String? color;
  final bool isDefault;
  final int? sortOrder;

  const NotebookFormState({
    this.name = '',
    this.description,
    this.color,
    this.isDefault = false,
    this.sortOrder,
  });

  NotebookFormState copyWith({
    String? name,
    String? description,
    String? color,
    bool? isDefault,
    int? sortOrder,
  }) {
    return NotebookFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
