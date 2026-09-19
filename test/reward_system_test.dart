import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/core/data/seed_data.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/lesson.dart';
import 'package:spellcraft_academy/screens/puzzle/puzzle_game_screen.dart';
import 'package:spellcraft_academy/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-user-rewards-1',
    email: 'apprentice@spellcraft.academy',
    displayName: 'Aria Silverglade',
  );

  final testLesson = Lesson.fromJson(SeedData.lessons[0]); // Spark (Lumos)

  group('Reward System - Unit Tests (ProgressService)', () {
    test('First-time completion with 0 mistakes awards 100 XP + 25 XP bonus',
        () async {
      final result = await ProgressService.instance.completeLesson(
        userId: testUser.id,
        lesson: testLesson,
        mistakeCount: 0,
      );

      expect(result.isFirstCompletion, isTrue);
      expect(result.baseXp, equals(100));
      expect(result.bonusXp, equals(25));
      expect(result.totalXpEarned, equals(125));
      expect(result.newTotalXp, equals(125));
      expect(result.newLevel, equals(1)); // 0-199 XP is Level 1
      expect(result.leveledUp, isFalse);

      final stats = await ProgressService.instance.getUserStats(testUser.id);
      expect(stats.totalXp, equals(125));
      expect(stats.currentLevel, equals(1));
      expect(stats.lessonsCompleted, equals(1));
      expect(stats.spellsUnlocked, equals(1));
    });

    test('Revisiting a completed lesson prevents duplicate XP and stats increments',
        () async {
      // First completion
      await ProgressService.instance.completeLesson(
        userId: testUser.id,
        lesson: testLesson,
        mistakeCount: 0,
      );

      final statsBefore =
          await ProgressService.instance.getUserStats(testUser.id);
      expect(statsBefore.totalXp, equals(125));

      // Replay the same lesson
      final replayResult = await ProgressService.instance.completeLesson(
        userId: testUser.id,
        lesson: testLesson,
        mistakeCount: 0,
      );

      expect(replayResult.isFirstCompletion, isFalse);
      expect(replayResult.baseXp, equals(0));
      expect(replayResult.bonusXp, equals(0));
      expect(replayResult.totalXpEarned, equals(0));
      expect(replayResult.newTotalXp, equals(125));

      final statsAfter =
          await ProgressService.instance.getUserStats(testUser.id);
      // No duplicate XP, no duplicate lessons completed, no duplicate spells
      expect(statsAfter.totalXp, equals(125));
      expect(statsAfter.lessonsCompleted, equals(1));
      expect(statsAfter.spellsUnlocked, equals(1));
    });

    test('First-time completion with mistakes awards only 100 XP (no bonus)',
        () async {
      const anotherUser = AppUser(
        id: 'test-user-mistakes-2',
        email: 'apprentice2@spellcraft.academy',
        displayName: 'Cedric Shadowend',
      );

      final result = await ProgressService.instance.completeLesson(
        userId: anotherUser.id,
        lesson: testLesson,
        mistakeCount: 2,
      );

      expect(result.isFirstCompletion, isTrue);
      expect(result.baseXp, equals(100));
      expect(result.bonusXp, equals(0));
      expect(result.totalXpEarned, equals(100));
      expect(result.newTotalXp, equals(100));
    });

    test('Crossing 200 XP threshold recalculates level to Level 2', () async {
      const levelingUser = AppUser(
        id: 'test-user-leveling-3',
        email: 'leveler@spellcraft.academy',
        displayName: 'Rowena Raven',
      );

      final lesson1 = Lesson.fromJson(SeedData.lessons[0]);
      final lesson2 = Lesson.fromJson(SeedData.lessons[1]);

      // Complete Lesson 1 with 0 mistakes -> 125 XP (Level 1)
      final res1 = await ProgressService.instance.completeLesson(
        userId: levelingUser.id,
        lesson: lesson1,
        mistakeCount: 0,
      );
      expect(res1.newTotalXp, equals(125));
      expect(res1.newLevel, equals(1));

      // Complete Lesson 2 with 0 mistakes -> 125 XP (Total 250 XP -> Level 2!)
      final res2 = await ProgressService.instance.completeLesson(
        userId: levelingUser.id,
        lesson: lesson2,
        mistakeCount: 0,
      );
      expect(res2.newTotalXp, equals(250));
      expect(res2.newLevel, equals(2));
      expect(res2.leveledUp, isTrue);

      final stats =
          await ProgressService.instance.getUserStats(levelingUser.id);
      expect(stats.totalXp, equals(250));
      expect(stats.currentLevel, equals(2));
      expect(stats.lessonsCompleted, equals(2));
      expect(stats.spellsUnlocked, equals(2));
    });
  });

  group('Reward System - Widget UI Tests', () {
    testWidgets(
        'Flawless completion displays +100 XP, +25 XP FLAWLESS BONUS, and total',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const flawlessUser = AppUser(
        id: 'test-ui-flawless',
        email: 'flawless@spellcraft.academy',
        displayName: 'Aria',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson, user: flawlessUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Solve Challenge 1/3 (Sequence: 16) with 0 mistakes
      await tester.tap(find.text('16'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Solve Challenge 2/3 (Symbol: ☀️) with 0 mistakes
      await tester.tap(find.text('☀️'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Solve Challenge 3/3 (Pattern: ✨) with 0 mistakes
      final options = find.text('✨');
      await tester.tap(options.first);
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify UI Badges
      expect(find.text('✨ SPELL MASTERED ✨'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('+25 XP FLAWLESS BONUS'), findsOneWidget);
      expect(find.text('Total Earned: +125 XP'), findsOneWidget);
    });

    testWidgets(
        'Completion with mistake displays +100 XP without flawless bonus',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const mistakeUser = AppUser(
        id: 'test-ui-mistake',
        email: 'mistake@spellcraft.academy',
        displayName: 'Cedric',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson, user: mistakeUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Deliberately make a mistake first (Select 10 instead of 16)
      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      expect(find.textContaining('The spell fizzled.'), findsOneWidget);

      // Now solve correctly
      await tester.tap(find.text('16'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Solve 2/3
      await tester.tap(find.text('☀️'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Solve 3/3
      final options = find.text('✨');
      await tester.tap(options.first);
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify UI
      expect(find.text('✨ SPELL MASTERED ✨'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('+25 XP FLAWLESS BONUS'), findsNothing);
      expect(find.text('Total Earned: +100 XP'), findsOneWidget);
    });

    testWidgets(
        'Revisiting a completed lesson displays Practice Session banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const replayUser = AppUser(
        id: 'test-ui-replay',
        email: 'replay@spellcraft.academy',
        displayName: 'Replayer',
      );

      // Pre-complete the lesson
      await ProgressService.instance.completeLesson(
        userId: replayUser.id,
        lesson: testLesson,
        mistakeCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PuzzleGameScreen(lesson: testLesson, user: replayUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Solve all 3 challenges on replay
      await tester.tap(find.text('16'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('☀️'));
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      final options = find.text('✨');
      await tester.tap(options.first);
      await tester.pump();
      await tester.tap(find.text('CAST SPELL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));

      // Replay UI
      expect(find.text('✦ LESSON REVISITED ✦'), findsOneWidget);
      expect(
        find.text('Practice Session • Already Mastered'),
        findsOneWidget,
      );
    });
  });
}
