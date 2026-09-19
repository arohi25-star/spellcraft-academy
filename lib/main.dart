import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'models/app_user.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/auth_service.dart';
import 'widgets/magic_loading_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  runApp(const SpellCraftApp());
}

class SpellCraftApp extends StatelessWidget {
  const SpellCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpellCraft Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

/// Authentication Gate:
/// - If a valid persisted session exists, immediately displays DashboardScreen.
/// - If unauthenticated, displays WelcomeScreen.
/// - Reacts dynamically to sign-in and sign-out events.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        if (!AuthService.instance.isInitialized) {
          return const Scaffold(
            body: Center(
              child: MagicLoadingIndicator(message: 'Consulting the magical archives...'),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return DashboardScreen(user: user);
        }

        return const WelcomeScreen();
      },
    );
  }
}
