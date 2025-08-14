/// Share permissions for notes
class SharePermissions {
  final bool canRead;
  final bool canWrite;
  final bool canShare;
  final bool canDelete;

  const SharePermissions({
    required this.canRead,
    required this.canWrite,
    required this.canShare,
    required this.canDelete,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharePermissions &&
          runtimeType == other.runtimeType &&
          canRead == other.canRead &&
          canWrite == other.canWrite &&
          canShare == other.canShare &&
          canDelete == other.canDelete;

  @override
  int get hashCode =>
      canRead.hashCode ^
      canWrite.hashCode ^
      canShare.hashCode ^
      canDelete.hashCode;

  factory SharePermissions.fromJson(Map<String, dynamic> json) {
    return SharePermissions(
      canRead: json['can_read'] ?? false,
      canWrite: json['can_write'] ?? false,
      canShare: json['can_share'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_read': canRead,
      'can_write': canWrite,
      'can_share': canShare,
      'can_delete': canDelete,
    };
  }

  /// Create read-only permissions
  factory SharePermissions.readOnly() {
    return const SharePermissions(
      canRead: true,
      canWrite: false,
      canShare: false,
      canDelete: false,
    );
  }

  /// Create read-write permissions
  factory SharePermissions.readWrite() {
    return const SharePermissions(
      canRead: true,
      canWrite: true,
      canShare: false,
      canDelete: false,
    );
  }

  /// Create full permissions
  factory SharePermissions.full() {
    return const SharePermissions(
      canRead: true,
      canWrite: true,
      canShare: true,
      canDelete: true,
    );
  }
}

/// Share type for notes
enum ShareType {
  public,
  user,
  email,
}

extension ShareTypeExtension on ShareType {
  String get value {
    switch (this) {
      case ShareType.public:
        return 'public';
      case ShareType.user:
        return 'user';
      case ShareType.email:
        return 'email';
    }
  }

  static ShareType fromString(String value) {
    switch (value) {
      case 'public':
        return ShareType.public;
      case 'user':
        return ShareType.user;
      case 'email':
        return ShareType.email;
      default:
        return ShareType.public;
    }
  }
}

/// Share request model
class ShareRequest {
  final String noteId;
  final ShareType shareType;
  final SharePermissions permissions;
  final DateTime? expiresAt;
  final String? password;
  final String? userEmail; // for user/email sharing

  const ShareRequest({
    required this.noteId,
    required this.shareType,
    required this.permissions,
    this.expiresAt,
    this.password,
    this.userEmail,
  });

  factory ShareRequest.fromJson(Map<String, dynamic> json) {
    return ShareRequest(
      noteId: json['note_id'] ?? '',
      shareType: ShareTypeExtension.fromString(json['share_type'] ?? 'public'),
      permissions: SharePermissions.fromJson(json['permissions'] ?? {}),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      password: json['password'],
      userEmail: json['user_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note_id': noteId,
      'share_type': shareType.value,
      'permissions': permissions.toJson(),
      'expires_at': expiresAt?.toIso8601String(),
      'password': password,
      if (userEmail != null) 'user_email': userEmail,
    };
  }
}

/// Shared note model
class SharedNote {
  final String shareId;
  final String noteId;
  final String ownerId;
  final String sharedBy;
  final ShareType shareType;
  final SharePermissions permissions;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final String? noteTitle;
  final String? noteContent;

  const SharedNote({
    required this.shareId,
    required this.noteId,
    required this.ownerId,
    required this.sharedBy,
    required this.shareType,
    required this.permissions,
    required this.createdAt,
    this.expiresAt,
    required this.accessCount,
    this.noteTitle,
    this.noteContent,
  });

  factory SharedNote.fromJson(Map<String, dynamic> json) {
    return SharedNote(
      shareId: json['share_id'] ?? '',
      noteId: json['note_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      sharedBy: json['shared_by'] ?? '',
      shareType: ShareTypeExtension.fromString(json['share_type'] ?? 'public'),
      permissions: SharePermissions.fromJson(json['permissions'] ?? {}),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      accessCount: json['access_count'] ?? 0,
      noteTitle: json['note_title'],
      noteContent: json['note_content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'share_id': shareId,
      'note_id': noteId,
      'owner_id': ownerId,
      'shared_by': sharedBy,
      'share_type': shareType.value,
      'permissions': permissions.toJson(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'access_count': accessCount,
      'note_title': noteTitle,
      'note_content': noteContent,
    };
  }

  /// Check if share has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted expiration date
  String? get formattedExpiresAt {
    if (expiresAt == null) return null;
    return '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}';
  }
}

/// Share response model
class ShareResponse {
  final String shareId;
  final String? shareUrl;
  final String message;

  const ShareResponse({
    required this.shareId,
    this.shareUrl,
    required this.message,
  });

  factory ShareResponse.fromJson(Map<String, dynamic> json) {
    return ShareResponse(
      shareId: json['share_id'] ?? '',
      shareUrl: json['share_url'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'share_id': shareId,
      'share_url': shareUrl,
      'message': message,
    };
  }
}
