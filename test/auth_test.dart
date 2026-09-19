import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellcraft_academy/main.dart';
import 'package:spellcraft_academy/services/auth_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    AuthService.instance.resetForTesting();
    await AuthService.instance.initialize();
  });

  tearDown(() async {
    await AuthService.instance.signOut();
  });

  testWidgets('Unauthenticated user sees WelcomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('SPELLCRAFT'), findsOneWidget);
    expect(find.text('ENTER THE ACADEMY'), findsOneWidget);
  });

  testWidgets('Navigating from Welcome CTA opens LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 1500));

    await tester.tap(find.text('ENTER THE ACADEMY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome, Apprentice'), findsOneWidget);
    expect(find.text('CONTINUE WITH GOOGLE'), findsOneWidget);
  });

  testWidgets('Google sign-in transitions to DashboardScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 1500));

    await tester.tap(find.text('ENTER THE ACADEMY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('CONTINUE WITH GOOGLE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('GOOD EVENING, APPRENTICE'), findsOneWidget);
    expect(find.text('ARIA SPELLWEAVER'), findsOneWidget);
    expect(find.text('ARCANE MASTERY'), findsOneWidget);
  });

  testWidgets('Logout from Dashboard via Profile returns to WelcomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 1500));

    // Sign in directly
    await AuthService.instance.signInWithGoogle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('ARIA SPELLWEAVER'), findsOneWidget);

    // Tap Avatar to open Profile screen
    await tester.tap(find.byType(CircleAvatar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Log out in Profile
    await tester.ensureVisible(find.text('LOG OUT'));
    await tester.pump();
    await tester.tap(find.text('LOG OUT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('ENTER THE ACADEMY'), findsOneWidget);
  });

  testWidgets('Persisted session skips login and opens Dashboard directly', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'spellcraft_dev_user_session',
      '{"id":"persisted-user-123","email":"scholar@spellcraft.academy","display_name":"Scholar Morgan"}',
    );
    AuthService.instance.resetForTesting();
    await AuthService.instance.initialize();

    await tester.pumpWidget(const SpellCraftApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SCHOLAR MORGAN'), findsOneWidget);
    expect(find.text('ARCANE MASTERY'), findsOneWidget);
    expect(find.text('ENTER THE ACADEMY'), findsNothing);
  });
}
