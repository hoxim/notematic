class Note {
  int id = 0; // ObjectBox ID
  String uuid; // API ID
  String title;
  String content;
  DateTime updatedAt;
  bool deleted;
  bool isDirty;
  bool isOffline; // Flag to distinguish offline vs online notes
  String notebookUuid;

  Note({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
    required this.notebookUuid,
  });

  Map<String, dynamic> toMap() => {
        'id': uuid, // API uses string ID
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'notebookUuid': notebookUuid,
      };

  static Note fromMap(Map<String, dynamic> map) => Note(
        uuid: map['id'] ?? map['_id'] ?? '',
        title: map['title'] ?? '',
        content: map['content'] ?? '',
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'])
            : (map['updated_at'] != null
                ? DateTime.parse(map['updated_at'])
                : (map['created_at'] != null
                    ? DateTime.parse(map['created_at'])
                    : DateTime.now())),
        deleted: map['deleted'] ?? false,
        isDirty: map['isDirty'] ?? false,
        isOffline: map['isOffline'] ?? false,
        notebookUuid: map['notebookUuid'] ?? map['notebook_id'] ?? '',
      );
}
