class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;
  bool deleted;
  bool isDirty;
  String notebookUuid;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
    required this.notebookUuid,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
    'isDirty': isDirty,
    'notebookUuid': notebookUuid,
  };

  static Note fromMap(Map<String, dynamic> map) => Note(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
    deleted: map['deleted'] ?? false,
    isDirty: map['isDirty'] ?? false,
    notebookUuid: map['notebookUuid'] ?? '',
  );
}
