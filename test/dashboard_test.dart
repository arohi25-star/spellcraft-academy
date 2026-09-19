import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/screens/dashboard/dashboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-apprentice-1',
    email: 'merlin@spellcraft.academy',
    displayName: 'Merlin Ambrosius',
  );

  testWidgets('Dashboard displays user greeting, stats, and school cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(user: testUser),
      ),
    );

    // Initial loading state
    expect(find.text('Opening the Academy Dashboard...'), findsOneWidget);

    // Wait for data load and entrance animation
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));

    // User greeting & name
    expect(find.text('GOOD EVENING, APPRENTICE'), findsOneWidget);
    expect(find.text('MERLIN AMBROSIUS'), findsOneWidget);

    // Level and XP section
    expect(find.text('ARCANE MASTERY'), findsOneWidget);
    expect(find.text('TOTAL XP: 0'), findsOneWidget);
    expect(find.text('LEVEL 1'), findsOneWidget);

    // Lessons & spells count
    expect(find.text('0 / 9'), findsNWidgets(2));
    expect(find.text('Lessons Completed'), findsOneWidget);
    expect(find.text('Spells Mastered'), findsOneWidget);

    // Continue Learning Action
    expect(find.text('CONTINUE LEARNING'), findsOneWidget);
    expect(find.text('RESUME'), findsOneWidget);

    // 3 Magical Schools
    expect(find.text('CHOOSE YOUR PATH'), findsOneWidget);
    expect(find.text('ELEMENTAL ARTS'), findsOneWidget);
    expect(find.text('ARCANE RUNES'), findsOneWidget);
    expect(find.text('MYSTIC LOGIC'), findsOneWidget);

    // Open Spellbook CTA
    expect(find.text('OPEN SPELLBOOK'), findsOneWidget);
  });

  testWidgets('Tapping Open Spellbook navigates to SpellbookScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(user: testUser),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.ensureVisible(find.text('OPEN SPELLBOOK'));
    await tester.pump();
    await tester.tap(find.text('OPEN SPELLBOOK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SPELLBOOK ARCHIVES'), findsOneWidget);
  });

  testWidgets('Tapping Avatar navigates to ProfileScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(user: testUser),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.byType(CircleAvatar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Merlin Ambrosius'), findsOneWidget);
    expect(find.text('merlin@spellcraft.academy'), findsOneWidget);
    expect(find.text('LOG OUT'), findsOneWidget);
  });
}
