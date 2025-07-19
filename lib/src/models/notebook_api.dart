class Notebook {
  int id = 0; // ObjectBox ID
  String uuid; // API ID
  String name;
  String? description;
  String? color;
  DateTime updatedAt;
  bool deleted;
  bool isDirty;
  bool isOffline; // Flag to distinguish offline vs online notebooks

  Notebook({
    this.id = 0,
    required this.uuid,
    required this.name,
    this.description,
    this.color,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
    this.isOffline = false,
  });

  Map<String, dynamic> toMap() => {
        'id': uuid, // API uses string ID
        'name': name,
        'description': description,
        'color': color,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'isDirty': isDirty,
        'isOffline': isOffline,
      };

  static Notebook fromMap(Map<String, dynamic> map) => Notebook(
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
      );
}
