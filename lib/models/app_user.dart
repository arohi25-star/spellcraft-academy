/// Unified user model for SpellCraft Academy authenticated apprentices.
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Apprentice',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
