import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/core/data/seed_data.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/lesson.dart';
import 'package:spellcraft_academy/screens/spellbook/spell_detail_screen.dart';
import 'package:spellcraft_academy/screens/spellbook/spellbook_screen.dart';
import 'package:spellcraft_academy/services/progress_service.dart';
import 'package:spellcraft_academy/widgets/spell_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-grimoire-apprentice-1',
    email: 'grimoire@spellcraft.academy',
    displayName: 'Archmage Theron',
  );

  final testLesson1 = Lesson.fromJson(SeedData.lessons[0]); // Spark (Lumos)

  group('Spellbook Feature - Unit Tests (ProgressService)', () {
    test('Fresh apprentice sees 9 spells all locked with required lessons',
        () async {
      final spells =
          await ProgressService.instance.getSpellbookForUser(testUser.id);

      expect(spells.length, equals(9));
      expect(spells.every((s) => !s.isUnlocked), isTrue);
      expect(spells.first.name, equals('Lumos'));
      expect(
        spells.first.unlockRequirement,
        contains('Complete Elemental Arts — Lesson 01: Spark'),
      );
    });

    test('Completing a lesson unlocks the spell in the user spellbook',
        () async {
      // Complete Lesson 1 (Spark -> Lumos)
      await ProgressService.instance.completeLesson(
        userId: testUser.id,
        lesson: testLesson1,
        mistakeCount: 0,
      );

      final spells =
          await ProgressService.instance.getSpellbookForUser(testUser.id);
      expect(spells.length, equals(9));

      final lumos = spells.firstWhere((s) => s.name == 'Lumos');
      expect(lumos.isUnlocked, isTrue);
      expect(lumos.masteryLevel, equals('Flawless'));
      expect(lumos.xpEarned, equals(125));
      expect(lumos.unlockedAt, isNotNull);

      // Remaining 8 spells are still locked
      final lockedSpells = spells.where((s) => !s.isUnlocked).toList();
      expect(lockedSpells.length, equals(8));
    });
  });

  group('Spellbook Feature - Widget UI Tests', () {
    testWidgets('Spellbook displays 9 spells with lock icons when unearned',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const emptyUser = AppUser(
        id: 'user-empty-spells',
        email: 'empty@spellcraft.academy',
        displayName: 'Novice',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SpellbookScreen(user: emptyUser),
        ),
      );

      expect(find.text('Opening your spellbook...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SPELLBOOK ARCHIVES'), findsOneWidget);
      expect(find.text('DISCOVERED SPELLS'), findsOneWidget);
      expect(find.text('0 / 9 Mastered'), findsOneWidget);

      // 9 spell cards rendered
      expect(find.byType(SpellCard), findsNWidgets(9));
      expect(find.text('LUMOS'), findsOneWidget);
      expect(find.text('IGNIS'), findsOneWidget);
      expect(find.text('AQUA'), findsOneWidget);
    });

    testWidgets('Tapping a locked spell shows required lesson dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const noviceUser = AppUser(
        id: 'user-novice-dialog',
        email: 'novice@spellcraft.academy',
        displayName: 'Novice',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SpellbookScreen(user: noviceUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap locked LUMOS card
      await tester.tap(find.text('LUMOS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Requirement Dialog appears
      expect(find.text('SPELL SEALED'), findsOneWidget);
      expect(find.text('LUMOS'), findsNWidgets(2)); // Card + Dialog title
      expect(
        find.textContaining('Complete Elemental Arts — Lesson 01: Spark'),
        findsNWidgets(2), // 1 in SpellCard + 1 in Dialog body
      );
      expect(find.text('RETURN'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('RETURN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SPELL SEALED'), findsNothing);
    });

    testWidgets(
        'Unlocked spell displays mastery and tapping opens SpellDetailScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const masteredUser = AppUser(
        id: 'user-mastered-spells',
        email: 'master@spellcraft.academy',
        displayName: 'Master Mage',
      );

      // Pre-complete Lumos
      await ProgressService.instance.completeLesson(
        userId: masteredUser.id,
        lesson: testLesson1,
        mistakeCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SpellbookScreen(user: masteredUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // 1 / 9 Mastered
      expect(find.text('1 / 9 Mastered'), findsOneWidget);
      expect(find.text('Mastery: '), findsOneWidget);
      expect(find.text('Flawless'), findsOneWidget);

      // Tap unlocked Lumos
      await tester.tap(find.text('LUMOS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // We are now in SpellDetailScreen!
      expect(find.byType(SpellDetailScreen), findsOneWidget);
      expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
      expect(find.text('Illuminates the darkest academy catacombs.'), findsOneWidget);
      expect(find.text('+125 XP'), findsOneWidget);
      expect(find.text('Flawless'), findsOneWidget);
      expect(find.text('RETURN TO SPELLBOOK'), findsOneWidget);

      // Return to Spellbook
      await tester.tap(find.text('RETURN TO SPELLBOOK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SpellDetailScreen), findsNothing);
      expect(find.byType(SpellbookScreen), findsOneWidget);
    });
  });
}
