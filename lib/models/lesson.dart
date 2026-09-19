/// Model representing an academy lesson with its associated unlockable spell.
class Lesson {
  final String id;
  final String schoolId;
  final String title;
  final String description;
  final String spellName;
  final String spellDescription;
  final String spellIcon;
  final int lessonOrder;

  const Lesson({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.description,
    required this.spellName,
    required this.spellDescription,
    required this.spellIcon,
    this.lessonOrder = 1,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      spellName: json['spell_name'] as String? ?? '',
      spellDescription: json['spell_description'] as String? ?? '',
      spellIcon: json['spell_icon'] as String? ?? '✨',
      lessonOrder: (json['lesson_order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'description': description,
      'spell_name': spellName,
      'spell_description': spellDescription,
      'spell_icon': spellIcon,
      'lesson_order': lessonOrder,
    };
  }
}
