import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/models/app_user.dart';
import 'package:spellcraft_academy/models/user_stats.dart';
import 'package:spellcraft_academy/screens/profile/profile_screen.dart';
import 'package:spellcraft_academy/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testUser = AppUser(
    id: 'test-user-profile-1',
    email: 'morgana@spellcraft.academy',
    displayName: 'Morgana Le Fay',
    avatarUrl: 'https://lh3.googleusercontent.com/a/mock-avatar-id',
  );

  const testStats = UserStats(
    userId: 'test-user-profile-1',
    totalXp: 350,
    currentLevel: 2,
    lessonsCompleted: 3,
    spellsUnlocked: 4,
  );

  group('Profile Screen Tests (PRD Section 18)', () {
    testWidgets(
        'Displays Google profile image, display name, email, and arcane level',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(
            user: testUser,
            stats: testStats,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Header title
      expect(find.text('APPRENTICE PROFILE'), findsOneWidget);

      // Google Profile Image (CircleAvatar)
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Display name
      expect(find.text('Morgana Le Fay'), findsOneWidget);

      // Email
      expect(find.text('morgana@spellcraft.academy'), findsOneWidget);

      // Current level
      expect(find.text('CURRENT LEVEL: 2'), findsOneWidget);
    });

    testWidgets(
        'Displays Total XP, Lessons Completed, and Spells Unlocked',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(
            user: testUser,
            stats: testStats,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Total XP
      expect(find.text('TOTAL XP'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);

      // Lessons Completed
      expect(find.text('LESSONS COMPLETED'), findsOneWidget);
      expect(find.text('3 / 9'), findsOneWidget);

      // Spells Unlocked
      expect(find.text('SPELLS UNLOCKED'), findsOneWidget);
      expect(find.text('4 / 9'), findsOneWidget);
    });

    testWidgets(
        'Displays fallback monogram when Google avatar is not available',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const userWithoutAvatar = AppUser(
        id: 'user-no-avatar',
        email: 'novice@spellcraft.academy',
        displayName: 'Arthur Pendragon',
        avatarUrl: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(
            user: userWithoutAvatar,
            stats: testStats,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // First letter monogram fallback
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Arthur Pendragon'), findsOneWidget);
      expect(find.text('novice@spellcraft.academy'), findsOneWidget);
    });

    testWidgets(
        'Hydrates user stats asynchronously when stats parameter is omitted',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(
            user: testUser,
          ),
        ),
      );

      // Initial loading state
      expect(find.text('Opening your grimoire archives...'), findsOneWidget);

      // Wait for async load
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('APPRENTICE PROFILE'), findsOneWidget);
      expect(find.text('Morgana Le Fay'), findsOneWidget);
      expect(find.text('CURRENT LEVEL: 1'), findsOneWidget);
      expect(find.text('TOTAL XP'), findsOneWidget);
      expect(find.text('LESSONS COMPLETED'), findsOneWidget);
      expect(find.text('SPELLS UNLOCKED'), findsOneWidget);
    });

    testWidgets(
        'Tapping [ LOG OUT ] calls AuthService.instance.signOut',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(
            user: testUser,
            stats: testStats,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify button is present
      final logoutButton = find.text('LOG OUT');
      expect(logoutButton, findsOneWidget);

      // Tap logout
      await tester.tap(logoutButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // AuthService should reflect sign out
      expect(AuthService.instance.currentUser, isNull);
    });

    testWidgets(
        'Top navigation return button pops route back to academy',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      transitionDuration: const Duration(milliseconds: 100),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 100),
                      pageBuilder: (_, _, _) => const ProfileScreen(
                        user: testUser,
                        stats: testStats,
                      ),
                    ),
                  );
                },
                child: const Text('GO TO PROFILE'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('GO TO PROFILE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('APPRENTICE PROFILE'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Return to Academy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('GO TO PROFILE'), findsOneWidget);
      expect(find.text('APPRENTICE PROFILE'), findsNothing);
    });
  });
}
