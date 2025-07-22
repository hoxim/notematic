// Unified Note model that works with both API and local database
// This model combines the best of both worlds:
// - API compatibility for server sync
// - Conflict resolution with version tracking
// - Offline-first capabilities
class UnifiedNote {
  int id = 0; // Local DB ID (Drift)

  // Core fields
  String uuid; // API ID for sync
  String title;
  String content;
  String notebookUuid;

  // Timestamps
  DateTime createdAt;
  DateTime updatedAt;

  // Sync flags
  bool deleted;
  bool isDirty; // Needs sync to server
  bool isOffline; // Created offline

  // Version tracking for conflict resolution
  String? localVersion; // Local version timestamp
  String? serverVersion; // Server version from CouchDB
  String? lastSyncAt; // Last successful sync timestamp

  // Metadata
  List<String> tags; // Note tags
  String? color; // Note color
  int? priority; // Note priority (1-5)

  // Relationships
  String? notebookName; // Cached notebook name for UI
  int? noteCount; // Cached note count for UI

  UnifiedNote({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.content,
    required this.notebookUuid,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
    this.localVersion,
    this.serverVersion,
    this.lastSyncAt,
    this.tags = const [],
    this.color,
    this.priority,
    this.notebookName,
    this.noteCount,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a new note (offline-first)
  static UnifiedNote create({
    required String title,
    required String content,
    required String notebookUuid,
    List<String> tags = const [],
    String? color,
    int? priority,
  }) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();

    return UnifiedNote(
      uuid: timestamp, // Will be replaced by server ID after sync
      title: title,
      content: content,
      notebookUuid: notebookUuid,
      createdAt: now,
      updatedAt: now,
      isOffline: true,
      isDirty: true,
      localVersion: timestamp,
      tags: tags,
      color: color,
      priority: priority,
    );
  }

  /// Create from API response
  static UnifiedNote fromApi(Map<String, dynamic> map) {
    final now = DateTime.now();
    return UnifiedNote(
      uuid: map['uuid'] ?? map['id'] ?? map['_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      notebookUuid: map['notebookUuid'] ?? map['notebook_id'] ?? '',
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at'], now),
      updatedAt: _parseDateTime(map['updatedAt'] ?? map['updated_at'], now),
      deleted: map['deleted'] ?? false,
      isDirty: false, // API data is clean
      isOffline: false, // API data is online
      serverVersion: map['_rev'] ?? map['version'], // CouchDB revision
      lastSyncAt: now.toIso8601String(),
      tags: _parseTags(map['tags']),
      color: map['color'],
      priority: map['priority'],
      notebookName: map['notebookName'],
      noteCount: map['noteCount'],
    );
  }

  /// Convert to API format
  Map<String, dynamic> toApi() => {
        'uuid': uuid,
        'title': title,
        'content': content,
        'notebookUuid': notebookUuid,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'tags': tags,
        'color': color,
        'priority': priority,
      };

  /// Convert to API format (alias for toApi)
  Map<String, dynamic> toApiMap() => toApi();

  /// Convert to UI format (for display)
  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'title': title,
        'content': content,
        'notebookUuid': notebookUuid,
        'notebookName': notebookName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'tags': tags,
        'color': color,
        'priority': priority,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
        'lastSyncAt': lastSyncAt,
      };

  /// Mark as synced with server
  void markAsSynced(String serverVersion) {
    isOffline = false;
    isDirty = false;
    this.serverVersion = serverVersion;
    lastSyncAt = DateTime.now().toIso8601String();
  }

  /// Mark as needing sync
  void markAsDirty() {
    isDirty = true;
    updatedAt = DateTime.now();
    localVersion = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Update note content
  void update({
    String? title,
    String? content,
    String? notebookUuid,
    List<String>? tags,
    String? color,
    int? priority,
  }) {
    if (title != null) this.title = title;
    if (content != null) this.content = content;
    if (notebookUuid != null) this.notebookUuid = notebookUuid;
    if (tags != null) this.tags = tags;
    if (color != null) this.color = color;
    if (priority != null) this.priority = priority;

    markAsDirty();
  }

  /// Soft delete
  void delete() {
    deleted = true;
    markAsDirty();
  }

  /// Restore from soft delete
  void restore() {
    deleted = false;
    markAsDirty();
  }

  /// Check if note needs sync
  bool get needsSync => isDirty || isOffline;

  /// Check if note is synced
  bool get isSynced => !isDirty && !isOffline && serverVersion != null;

  /// Get display title
  String get displayTitle => title.isNotEmpty ? title : 'Untitled';

  /// Get display content preview
  String get contentPreview {
    if (content.isEmpty) return '';
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  /// Parse datetime from various formats
  static DateTime _parseDateTime(dynamic value, DateTime fallback) {
    if (value == null) return fallback;

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return fallback;
  }

  /// Parse tags from various formats
  static List<String> _parseTags(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((tag) => tag.toString()).toList();
    } else if (value is String) {
      return value
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return [];
  }

  @override
  String toString() {
    return 'UnifiedNote(id: $id, uuid: $uuid, title: $title, isDirty: $isDirty, isOffline: $isOffline)';
  }
}
