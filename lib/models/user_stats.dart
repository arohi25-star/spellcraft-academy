/// Model representing aggregated user progress statistics from Supabase user_stats table.
class UserStats {
  final String userId;
  final int totalXp;
  final int currentLevel;
  final int lessonsCompleted;
  final int spellsUnlocked;
  final DateTime? updatedAt;

  const UserStats({
    required this.userId,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.lessonsCompleted = 0,
    this.spellsUnlocked = 0,
    this.updatedAt,
  });

  /// Calculates XP within current level window (200 XP per level)
  int get currentLevelXp => totalXp % 200;

  /// Next level milestone is always 200 XP for the level band
  int get nextLevelXp => 200;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['user_id'] as String? ?? '',
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      lessonsCompleted: (json['lessons_completed'] as num?)?.toInt() ?? 0,
      spellsUnlocked: (json['spells_unlocked'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_xp': totalXp,
      'current_level': currentLevel,
      'lessons_completed': lessonsCompleted,
      'spells_unlocked': spellsUnlocked,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
