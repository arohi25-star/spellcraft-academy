import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/core/data/seed_data.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/lesson.dart';
import 'package:spellcraft_academy/models/school.dart';
import 'package:spellcraft_academy/models/spell.dart';
import 'package:spellcraft_academy/models/user_stats.dart';
import 'package:spellcraft_academy/screens/dashboard/dashboard_screen.dart';
import 'package:spellcraft_academy/screens/lessons/lesson_selection_screen.dart';
import 'package:spellcraft_academy/screens/login/login_screen.dart';
import 'package:spellcraft_academy/screens/profile/profile_screen.dart';
import 'package:spellcraft_academy/screens/puzzle/puzzle_game_screen.dart';
import 'package:spellcraft_academy/screens/schools/school_selection_screen.dart';
import 'package:spellcraft_academy/screens/spellbook/spell_detail_screen.dart';
import 'package:spellcraft_academy/screens/spellbook/spellbook_screen.dart';
import 'package:spellcraft_academy/screens/welcome/welcome_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'responsive-audit-user',
    email: 'scholar@spellcraft.academy',
    displayName: 'Scholar Morgan',
    avatarUrl: null,
  );

  const testStats = UserStats(
    userId: 'responsive-audit-user',
    totalXp: 325,
    currentLevel: 2,
    lessonsCompleted: 3,
    spellsUnlocked: 3,
  );

  final testSchool = School.fromJson(SeedData.schools[0]);
  final testLesson = Lesson.fromJson(SeedData.lessons[0]);

  final testSpell = Spell(
    id: 'spell-lumos',
    name: 'Lumos',
    description: 'Illuminates the darkest academy catacombs.',
    icon: '✦',
    schoolName: 'Elemental Arts',
    schoolId: testSchool.id,
    lessonId: testLesson.id,
    isUnlocked: true,
    masteryLevel: 'Flawless',
    xpEarned: 125,
    unlockedAt: DateTime(2026, 9, 18),
  );

  final viewports = [
    // Mobile portrait
    const Size(360, 640),
    const Size(375, 667),
    const Size(390, 844),
    // Mobile landscape / short viewports
    const Size(640, 360),
    const Size(667, 375),
    // Tablet portrait & landscape
    const Size(768, 1024),
    const Size(1024, 768),
    // Desktop widescreen
    const Size(1280, 800),
    const Size(1440, 900),
  ];

  group('Responsive UI Audit Across All 10 Screens', () {
    for (final size in viewports) {
      testWidgets('1. WelcomeScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: WelcomeScreen(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('SPELLCRAFT'), findsOneWidget);
        expect(find.text('ENTER THE ACADEMY'), findsOneWidget);
      });

      testWidgets('2. LoginScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: LoginScreen(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Welcome, Apprentice'), findsOneWidget);
        expect(find.text('CONTINUE WITH GOOGLE'), findsOneWidget);
      });

      testWidgets('3. DashboardScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: DashboardScreen(user: testUser),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('SCHOLAR MORGAN'), findsOneWidget);
        expect(find.text('ARCANE MASTERY'), findsOneWidget);
        expect(find.text('OPEN SPELLBOOK'), findsOneWidget);
      });

      testWidgets('4. SchoolSelectionScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: SchoolSelectionScreen(user: testUser),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('MAGICAL SCHOOLS'), findsOneWidget);
        expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
      });

      testWidgets('5. LessonSelectionScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: LessonSelectionScreen(
              school: testSchool,
              user: testUser,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
        expect(find.text('SPARK'), findsOneWidget);
      });

      testWidgets('6. PuzzleGameScreen (Puzzle View) at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: PuzzleGameScreen(
              lesson: testLesson,
              user: testUser,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('LESSON 01'), findsOneWidget);
        expect(find.text('CHALLENGE 1 / 3'), findsOneWidget);
        expect(find.text('CAST SPELL'), findsOneWidget);
      });

      testWidgets('7. Lesson Success Screen View at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: PuzzleGameScreen(
              lesson: testLesson,
              user: testUser,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        // Solve puzzle 1 (sequence 16)
        await tester.ensureVisible(find.text('16'));
        await tester.tap(find.text('16'));
        await tester.pump();
        await tester.ensureVisible(find.text('CAST SPELL'));
        await tester.tap(find.text('CAST SPELL'));
        await tester.pump(const Duration(milliseconds: 1000));

        // Solve puzzle 2 (symbol ☀️)
        await tester.ensureVisible(find.text('☀️'));
        await tester.tap(find.text('☀️'));
        await tester.pump();
        await tester.ensureVisible(find.text('CAST SPELL'));
        await tester.tap(find.text('CAST SPELL'));
        await tester.pump(const Duration(milliseconds: 1000));

        // Solve puzzle 3 (pattern ✨)
        await tester.ensureVisible(find.text('✨').last);
        await tester.tap(find.text('✨').last);
        await tester.pump();
        await tester.ensureVisible(find.text('CAST SPELL'));
        await tester.tap(find.text('CAST SPELL'));
        await tester.pump(const Duration(milliseconds: 1500));

        expect(find.text('LUMOS'), findsOneWidget);
        expect(find.text('OPEN SPELLBOOK'), findsOneWidget);
        expect(find.text('RETURN TO ACADEMY'), findsOneWidget);
      });

      testWidgets('8. SpellbookScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: SpellbookScreen(user: testUser),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('SPELLBOOK ARCHIVES'), findsOneWidget);
        expect(find.text('DISCOVERED SPELLS'), findsOneWidget);
      });

      testWidgets('9. SpellDetailScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: SpellDetailScreen(spell: testSpell),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('LUMOS'), findsOneWidget);
        expect(find.text('RETURN TO SPELLBOOK'), findsOneWidget);
      });

      testWidgets('10. ProfileScreen at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: ProfileScreen(
              user: testUser,
              stats: testStats,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('APPRENTICE PROFILE'), findsOneWidget);
        expect(find.text('LOG OUT'), findsOneWidget);
      });
    }
  });
}
