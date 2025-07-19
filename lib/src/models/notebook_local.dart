class NotebookLocal {
  int id = 0; // ObjectBox ID
  String uuid; // API ID for sync
  String name;
  String? description;
  String? color;
  DateTime updatedAt;
  bool deleted;
  bool isDirty; // Needs sync
  bool isOffline; // Created offline
  String? localVersion; // Local version for conflict resolution
  String? serverVersion; // Server version from CouchDB

  NotebookLocal({
    this.id = 0,
    required this.uuid,
    required this.name,
    this.description,
    this.color,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
    this.localVersion,
    this.serverVersion,
  });

  // Convert to API model
  Map<String, dynamic> toApiMap() => {
        'id': uuid,
        'name': name,
        'description': description,
        'color': color,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
      };

  // Create from API model
  static NotebookLocal fromApiMap(Map<String, dynamic> map) => NotebookLocal(
        uuid: map['id'] ?? map['_id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'],
        color: map['color'],
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'])
            : (map['created_at'] != null
                ? DateTime.parse(map['created_at'])
                : DateTime.now()),
        deleted: map['deleted'] ?? false,
        isDirty: map['isDirty'] ?? false,
        isOffline: map['isOffline'] ?? false,
        localVersion: map['localVersion'],
        serverVersion: map['serverVersion'],
      );

  // Create offline notebook
  static NotebookLocal createOffline({
    required String name,
    String? description,
    String? color,
  }) {
    return NotebookLocal(
      uuid: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: color,
      updatedAt: DateTime.now(),
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
