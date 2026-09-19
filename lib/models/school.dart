/// Model representing a magical school in SpellCraft Academy.
class School {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int sortOrder;

  const School({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.sortOrder = 1,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '✦',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }
}
