class Notebook {
  String id;
  String name;
  String? description;
  String? color;
  DateTime updatedAt;
  bool deleted;
  bool isDirty;

  Notebook({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.updatedAt,
    this.deleted = false,
    this.isDirty = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
    'isDirty': isDirty,
  };

  static Notebook fromMap(Map<String, dynamic> map) => Notebook(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    description: map['description'],
    color: map['color'],
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
    deleted: map['deleted'] ?? false,
    isDirty: map['isDirty'] ?? false,
  );
}
