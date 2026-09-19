import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/core/data/seed_data.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/lesson.dart';
import 'package:spellcraft_academy/models/school.dart';
import 'package:spellcraft_academy/screens/lessons/lesson_selection_screen.dart';
import 'package:spellcraft_academy/screens/puzzle/puzzle_game_screen.dart';
import 'package:spellcraft_academy/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-apprentice-1',
    email: 'merlin@spellcraft.academy',
    displayName: 'Merlin Ambrosius',
  );

  final testLesson1 = Lesson.fromJson(SeedData.lessons[0]); // Spark (Lumos)
  final testLesson2 = Lesson.fromJson(SeedData.lessons[1]); // Flame (Ignis)
  final testLesson8 = Lesson.fromJson(SeedData.lessons[7]); // Mind Mirror (Mind Echo)

  group('Puzzle Gameplay Tests - Lesson 1 (Spark)', () {
    testWidgets('Renders first puzzle and shows progress 1 / 3',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson1, user: testUser),
        ),
      );

      // Loading indicator
      expect(find.text('Summoning lesson challenges...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Progress Header
      expect(find.text('CHALLENGE 1 / 3'), findsOneWidget);
      expect(find.text('SPARK'), findsOneWidget);
      expect(find.text('LESSON 01'), findsOneWidget);

      // Puzzle 1 is sequence: 2 -> 4 -> 8 -> ?
      expect(find.text('COMPLETE THE SEQUENCE'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.text('CAST SPELL'), findsOneWidget);
    });

    testWidgets(
        'Incorrect answer shows friendly retry message without failing lesson',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson1, user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Select wrong answer '10' (correct is 16)
      await tester.tap(find.text('10'));
      await tester.pump();

      // Cast spell
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();

      // Friendly retry feedback
      expect(find.textContaining('The spell fizzled.'), findsOneWidget);
      expect(find.textContaining('Try again, apprentice.'), findsOneWidget);

      // Still on challenge 1/3, not failed
      expect(find.text('CHALLENGE 1 / 3'), findsOneWidget);

      // User can retry immediately: select correct answer '16'
      await tester.tap(find.text('16'));
      await tester.pump();

      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();

      expect(find.text('Spell cast successfully!'), findsOneWidget);
      expect(find.text('SOLVED'), findsOneWidget);

      // Settle the transition timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets(
        'Solving all 3 puzzles completes the lesson and shows spell celebration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson1, user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Puzzle 1 (Sequence): Correct answer = 16
      expect(find.text('CHALLENGE 1 / 3'), findsOneWidget);
      await tester.tap(find.text('16'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      // Advance to puzzle 2
      await tester.pump(const Duration(milliseconds: 800));

      // Puzzle 2 (Symbol Selection): Correct answer = ☀️
      expect(find.text('CHALLENGE 2 / 3'), findsOneWidget);
      expect(find.text('ARCANE SYMBOL CLUE'), findsOneWidget);
      await tester.tap(find.text('☀️'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      // Advance to puzzle 3
      await tester.pump(const Duration(milliseconds: 800));

      // Puzzle 3 (Pattern): Correct answer = ✨
      expect(find.text('CHALLENGE 3 / 3'), findsOneWidget);
      expect(find.text('PATTERN RECOGNITION'), findsOneWidget);
      // Tap ✨ option
      final patternOptions = find.text('✨');
      await tester.tap(patternOptions.first);
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();

      // Final puzzle completes the lesson
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));

      // Celebration Screen verification
      expect(find.text('✨ SPELL MASTERED ✨'), findsOneWidget);
      expect(find.text('LUMOS'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('OPEN SPELLBOOK'), findsOneWidget);
      expect(find.text('RETURN TO ACADEMY'), findsOneWidget);

      // Verify that progress is updated
      final completedIds =
          await ProgressService.instance.getCompletedLessonIds(testUser.id);
      expect(completedIds.contains(testLesson1.id), isTrue);
    });
  });

  group('Puzzle Gameplay Tests - All 5 Puzzle Types', () {
    testWidgets('Multiple Choice Puzzle in Lesson 2 functions properly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson2, user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Solve puzzle 1 (Sequence: 3 -> 9 -> 27 -> 81)
      await tester.tap(find.text('81'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Puzzle 2 in Lesson 2 is Multiple Choice: 'Which element feeds the core flame?'
      expect(find.text('CHALLENGE 2 / 3'), findsOneWidget);
      expect(find.text('Which element feeds the core flame?'), findsOneWidget);
      expect(find.text('Oxygen'), findsOneWidget);
      expect(find.text('Stone'), findsOneWidget);

      // Select Oxygen
      await tester.tap(find.text('Oxygen'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();

      expect(find.text('Spell cast successfully!'), findsOneWidget);
      // Settle transition timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets(
        'Memory Puzzle in Lesson 8 functions with Reveal and Recall phases',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson8, user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Solve puzzle 1 (Multiple Choice: 'What reflects without a surface?' -> 'An Echo')
      await tester.tap(find.text('An Echo'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Puzzle 2 in Lesson 8 is Memory: Reveal Phase
      expect(find.text('CHALLENGE 2 / 3'), findsOneWidget);
      expect(find.text('ARCANE VISION'), findsOneWidget);
      expect(find.text('I HAVE MEMORIZED THE VISION'), findsOneWidget);

      // Click to transition to Recall Phase
      await tester.tap(find.text('I HAVE MEMORIZED THE VISION'));
      await tester.pump();

      // Recall phase active
      expect(find.text('VISION CONCEALED'), findsOneWidget);
      expect(find.text('✦   ✦   ✦   ✦'), findsOneWidget);
      expect(
        find.text('Which arcane symbol was part of the celestial vision?'),
        findsOneWidget,
      );

      // Select correct memory symbol 🔮 (using .last to distinguish from header spell icon)
      await tester.tap(find.text('🔮').last);
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();

      expect(find.text('Spell cast successfully!'), findsOneWidget);
      // Settle transition timer
      await tester.pump(const Duration(milliseconds: 800));
    });
  });

  group('LessonSelectionScreen to PuzzleGameScreen Integration', () {
    testWidgets('Tapping BEGIN LESSON in dialog launches PuzzleGameScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testSchool = School.fromJson(SeedData.schools[0]);

      await tester.pumpWidget(
        MaterialApp(
          home: LessonSelectionScreen(school: testSchool, user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the unlocked lesson
      await tester.tap(find.text('LESSON 01'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog is open, now tap BEGIN LESSON
      expect(find.text('BEGIN LESSON'), findsOneWidget);
      await tester.tap(find.text('BEGIN LESSON'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we arrived at PuzzleGameScreen
      expect(find.text('CHALLENGE 1 / 3'), findsOneWidget);
    });
  });
}
