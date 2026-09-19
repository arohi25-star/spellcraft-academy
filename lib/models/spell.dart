/// Model representing a spell in the Academy's Spellbook.
class Spell {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String schoolName;
  final String schoolId;
  final String lessonId;
  final String lessonTitle;
  final int lessonOrder;
  final String masteryLevel;
  final bool isUnlocked;
  final int xpEarned;
  final DateTime? unlockedAt;
  final String? unlockRequirement;

  const Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.schoolName,
    required this.schoolId,
    required this.lessonId,
    this.lessonTitle = '',
    this.lessonOrder = 1,
    this.masteryLevel = 'Beginner',
    this.isUnlocked = false,
    this.xpEarned = 100,
    this.unlockedAt,
    this.unlockRequirement,
  });

  factory Spell.fromLesson({
    required String schoolName,
    required dynamic lessonJson,
    bool isUnlocked = false,
    String masteryLevel = 'Beginner',
    int xpEarned = 100,
    DateTime? unlockedAt,
    String? unlockRequirement,
  }) {
    return Spell(
      id: lessonJson['id'] as String? ?? '',
      name: lessonJson['spell_name'] as String? ?? '',
      description: lessonJson['spell_description'] as String? ?? '',
      icon: lessonJson['spell_icon'] as String? ?? '✨',
      schoolName: schoolName,
      schoolId: lessonJson['school_id'] as String? ?? '',
      lessonId: lessonJson['id'] as String? ?? '',
      lessonTitle: lessonJson['title'] as String? ?? '',
      lessonOrder: (lessonJson['lesson_order'] as num?)?.toInt() ?? 1,
      masteryLevel: masteryLevel,
      isUnlocked: isUnlocked,
      xpEarned: xpEarned,
      unlockedAt: unlockedAt,
      unlockRequirement: unlockRequirement,
    );
  }
}
