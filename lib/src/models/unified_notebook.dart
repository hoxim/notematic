// Unified Notebook model that works with both API and local database
// This model combines the best of both worlds:
// - API compatibility for server sync
// - Conflict resolution with version tracking
// - Offline-first capabilities
class UnifiedNotebook {
  int id = 0; // Local DB ID (Drift)

  // Core fields
  String uuid; // API ID for sync
  String name;
  String? description;
  String? color;

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
  int noteCount; // Number of notes in this notebook
  bool isDefault; // Is this the default notebook
  int? sortOrder; // Custom sort order

  // Relationships
  List<String> noteIds; // List of note UUIDs in this notebook

  UnifiedNotebook({
    this.id = 0,
    required this.uuid,
    required this.name,
    this.description,
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
    this.localVersion,
    this.serverVersion,
    this.lastSyncAt,
    this.noteCount = 0,
    this.isDefault = false,
    this.sortOrder,
    this.noteIds = const [],
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  /// Create a new notebook (offline-first)
  static UnifiedNotebook create({
    required String name,
    String? description,
    String? color,
    bool isDefault = false,
    int? sortOrder,
  }) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();

    return UnifiedNotebook(
      uuid: timestamp, // Will be replaced by server ID after sync
      name: name,
      description: description,
      color: color,
      createdAt: now,
      updatedAt: now,
      isOffline: true,
      isDirty: true,
      localVersion: timestamp,
      isDefault: isDefault,
      sortOrder: sortOrder,
    );
  }

  /// Create from API response
  static UnifiedNotebook fromApi(Map<String, dynamic> map) {
    final now = DateTime.now();

    return UnifiedNotebook(
      uuid: map['id'] ?? map['_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      color: map['color'],
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at'], now),
      updatedAt: _parseDateTime(map['updatedAt'] ?? map['updated_at'], now),
      deleted: map['deleted'] ?? false,
      isDirty: false, // API data is clean
      isOffline: false, // API data is online
      serverVersion: map['_rev'] ?? map['version'], // CouchDB revision
      lastSyncAt: now.toIso8601String(),
      noteCount: map['noteCount'] ?? 0,
      isDefault: map['isDefault'] ?? false,
      sortOrder: map['sortOrder'],
      noteIds: _parseNoteIds(map['noteIds']),
    );
  }

  /// Convert to API format
  Map<String, dynamic> toApi() => {
        'id': uuid,
        'name': name,
        'description': description,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
      };

  /// Convert to API format (alias for toApi)
  Map<String, dynamic> toApiMap() => toApi();

  /// Convert to UI format (for display)
  Map<String, dynamic> toMap() => {
        'id': uuid,
        'name': name,
        'description': description,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
        'noteCount': noteCount,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
        'localVersion': localVersion,
        'serverVersion': serverVersion,
        'lastSyncAt': lastSyncAt,
        'noteIds': noteIds,
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

  /// Update notebook content
  void update({
    String? name,
    String? description,
    String? color,
    bool? isDefault,
    int? sortOrder,
  }) {
    if (name != null) this.name = name;
    if (description != null) this.description = description;
    if (color != null) this.color = color;
    if (isDefault != null) this.isDefault = isDefault;
    if (sortOrder != null) this.sortOrder = sortOrder;

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

  /// Add note to notebook
  void addNote(String noteId) {
    if (!noteIds.contains(noteId)) {
      noteIds = [...noteIds, noteId];
      noteCount = noteIds.length;
      markAsDirty();
    }
  }

  /// Remove note from notebook
  void removeNote(String noteId) {
    if (noteIds.contains(noteId)) {
      noteIds = noteIds.where((id) => id != noteId).toList();
      noteCount = noteIds.length;
      markAsDirty();
    }
  }

  /// Update note count
  void updateNoteCount(int count) {
    noteCount = count;
    markAsDirty();
  }

  /// Check if notebook needs sync
  bool get needsSync => isDirty || isOffline;

  /// Check if notebook is synced
  bool get isSynced => !isDirty && !isOffline && serverVersion != null;

  /// Get display name
  String get displayName => name.isNotEmpty ? name : 'Untitled';

  /// Get display description
  String get displayDescription => description ?? '';

  /// Get color for UI
  String get displayColor => color ?? '#2196F3';

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

  /// Parse note IDs from various formats
  static List<String> _parseNoteIds(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((id) => id.toString()).toList();
    } else if (value is String) {
      return value
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList();
    }

    return [];
  }

  @override
  String toString() {
    return 'UnifiedNotebook(id: $id, uuid: $uuid, name: $name, noteCount: $noteCount, isDirty: $isDirty, isOffline: $isOffline)';
  }
}
