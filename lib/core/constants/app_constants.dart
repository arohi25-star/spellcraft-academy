/// Application constants and public Supabase client configuration.
/// 
/// Security rules:
/// - Never store the Supabase service-role key in Flutter code.
/// - Never hard-code private credentials.
/// - Public anon key and project URL are safe for client-side embedding.
abstract final class AppConstants {
  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://keojsrvavukicfksuxab.supabase.co',
  );

  /// Supabase public anonymous key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtlb2pzcnZhdnVraWNma3N1eGFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk3MzAwMjAsImV4cCI6MjEwNTMwNjAyMH0.mZ_9VLoiKhxn_8Kbi6tHdf9SImPgErEhT36AmHyUDuA',
  );

  /// Checks if valid Supabase credentials have been configured
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl.startsWith('https://');

  /// Academy XP constants (PRD Section 20)
  static const int xpPerLesson = 100;
  static const int flawlessBonusXp = 25;
  static const int xpPerLevel = 200;
}
