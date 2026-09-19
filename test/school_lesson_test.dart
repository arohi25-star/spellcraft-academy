import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/core/data/seed_data.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/school.dart';
import 'package:spellcraft_academy/screens/dashboard/dashboard_screen.dart';
import 'package:spellcraft_academy/screens/lessons/lesson_selection_screen.dart';
import 'package:spellcraft_academy/screens/schools/school_selection_screen.dart';
import 'package:spellcraft_academy/widgets/lesson_card.dart';
import 'package:spellcraft_academy/widgets/school_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-apprentice-1',
    email: 'merlin@spellcraft.academy',
    displayName: 'Merlin Ambrosius',
  );

  final testSchool = School.fromJson(SeedData.schools[0]); // Elemental Arts

  group('SchoolSelectionScreen Tests', () {
    testWidgets('Renders header and all 3 magical schools on desktop width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SchoolSelectionScreen(user: testUser),
        ),
      );

      // Loading state
      expect(find.text('Opening Academy halls...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Header verification
      expect(find.text('MAGICAL SCHOOLS'), findsOneWidget);
      expect(
        find.text(
            'Select a discipline of magic to embark on curriculum lessons and unlock ancient spells.'),
        findsOneWidget,
      );

      // 3 school cards rendered
      expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
      expect(find.text('ARCANE RUNES'), findsOneWidget);
      expect(find.text('MYSTIC LOGIC'), findsOneWidget);
      expect(find.byType(SchoolCard), findsNWidgets(3));
    });

    testWidgets('Renders successfully on mobile width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SchoolSelectionScreen(user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('MAGICAL SCHOOLS'), findsOneWidget);
      expect(find.byType(SchoolCard), findsNWidgets(3));
    });

    testWidgets('Tapping a SchoolCard navigates to LessonSelectionScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SchoolSelectionScreen(user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Elemental Arts card
      await tester.tap(find.text('ELEMENTAL ARTS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify we arrived at LessonSelectionScreen
      expect(find.text('CURRICULUM LESSONS'), findsOneWidget);
      expect(find.text('Sequential Unlock Required'), findsOneWidget);
    });
  });

  group('LessonSelectionScreen Tests', () {
    testWidgets(
        'Renders school banner and 3 lessons with sequential unlock rules',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 800);
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

      // Loading state
      expect(find.text('Consulting school archives...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // School banner
      expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
      expect(find.text('CURRICULUM LESSONS'), findsOneWidget);

      // 3 lessons rendered
      expect(find.byType(LessonCard), findsNWidgets(3));

      // First lesson is unlocked (order 1)
      expect(find.text('UNLOCKED'), findsOneWidget);
      // Other two lessons are locked initially
      expect(find.text('LOCKED'), findsNWidgets(2));
    });

    testWidgets('Tapping unlocked lesson shows dialog with lesson info',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 800);
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
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the unlocked lesson (Lesson 1)
      final lessonCards = find.byType(LessonCard);
      await tester.tap(lessonCards.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog pops up
      expect(find.text('LESSON 01 — SPARK'), findsOneWidget);
      expect(find.textContaining('SPELL REWARD:'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);

      // Tap CLOSE dismisses dialog
      await tester.tap(find.text('CLOSE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('CLOSE'), findsNothing);
    });

    testWidgets('Tapping locked lesson does NOT show preview dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 800);
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
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the locked lesson (Lesson 2, index 1)
      final lessonCards = find.byType(LessonCard);
      await tester.tap(lessonCards.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // No dialog opened
      expect(find.text('CLOSE'), findsNothing);
    });
  });

  group('Dashboard to School/Lesson Navigation Tests', () {
    testWidgets('Tapping ALL SCHOOLS opens SchoolSelectionScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));

      await tester.ensureVisible(find.text('All Schools'));
      await tester.pump();
      await tester.tap(find.text('All Schools'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('MAGICAL SCHOOLS'), findsOneWidget);
    });

    testWidgets(
        'Tapping SchoolCard in Dashboard opens LessonSelectionScreen directly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(user: testUser),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 700));

      await tester.ensureVisible(find.text('ELEMENTAL ARTS'));
      await tester.pump();
      await tester.tap(find.text('ELEMENTAL ARTS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CURRICULUM LESSONS'), findsOneWidget);
    });
  });
}
