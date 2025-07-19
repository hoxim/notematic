class NoteLocal {
  int id = 0; // ObjectBox ID
  String uuid; // API ID for sync
  String title;
  String content;
  DateTime updatedAt;
  bool deleted;
  bool isDirty; // Needs sync
  bool isOffline; // Created offline
  String notebookUuid;
  String? localVersion; // Local version for conflict resolution
  String? serverVersion; // Server version from CouchDB

  NoteLocal({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
    required this.notebookUuid,
    this.localVersion,
    this.serverVersion,
  });

  // Convert to API model
  Map<String, dynamic> toApiMap() => {
        'id': uuid,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'notebookUuid': notebookUuid,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
      };

  // Convert to Map for UI
  Map<String, dynamic> toMap() => {
        'id': uuid,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'notebookUuid': notebookUuid,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
      };

  // Create from API model
  static NoteLocal fromApiMap(Map<String, dynamic> map) => NoteLocal(
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
        localVersion: map['localVersion'],
        serverVersion: map['serverVersion'],
      );

  // Create offline note
  static NoteLocal createOffline({
    required String title,
    required String content,
    required String notebookUuid,
  }) {
    return NoteLocal(
      uuid: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      updatedAt: DateTime.now(),
      notebookUuid: notebookUuid,
      isOffline: true,
      isDirty: true,
      localVersion: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  // Mark as synced
  void markAsSynced(String serverVersion) {
    isOffline = false;
    isDirty = false;
    this.serverVersion = serverVersion;
  }

  // Mark as needing sync
  void markAsDirty() {
    isDirty = true;
    localVersion = DateTime.now().millisecondsSinceEpoch.toString();
  }
}
