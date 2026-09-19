import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user.dart';

/// Service managing Supabase authentication, session persistence,
/// Google OAuth, and auth state notifications.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const String _devSessionKey = 'spellcraft_dev_user_session';

  final StreamController<AppUser?> _authStreamController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;
  bool _isInitialized = false;

  @visibleForTesting
  bool isTestMode = false;

  /// Current authenticated user (null if unauthenticated)
  AppUser? get currentUser => _currentUser;

  /// Whether a valid user session is active
  bool get isAuthenticated => _currentUser != null;

  /// Whether the auth service has completed initialization
  bool get isInitialized => _isInitialized;

  /// Reactive stream of authentication changes
  Stream<AppUser?> get authStateChanges => _authStreamController.stream;

  @visibleForTesting
  void resetForTesting() {
    isTestMode = true;
    _isInitialized = false;
    _currentUser = null;
  }

  /// Initializes Supabase client and restores existing persisted sessions
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (AppConstants.isSupabaseConfigured && !isTestMode) {
      try {
        await Supabase.initialize(
          url: AppConstants.supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: AppConstants.supabaseAnonKey,
        );

        final client = Supabase.instance.client;
        final currentSupabaseUser = client.auth.currentUser;
        if (currentSupabaseUser != null) {
          _currentUser = _mapSupabaseUser(currentSupabaseUser);
        }

        // Listen for Supabase auth state events (Google OAuth redirects, refresh, logout)
        client.auth.onAuthStateChange.listen((data) {
          final session = data.session;
          if (session?.user != null) {
            _currentUser = _mapSupabaseUser(session!.user);
          } else {
            _currentUser = null;
          }
          _authStreamController.add(_currentUser);
        });
      } catch (e) {
        debugPrint('Supabase initialization error: $e');
      }
    } else {
      // Local dev session persistence when in test mode or unconfigured
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString(_devSessionKey);
      if (savedUserJson != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(savedUserJson);
          _currentUser = AppUser.fromJson(data);
        } catch (_) {
          await prefs.remove(_devSessionKey);
        }
      }
    }

    _isInitialized = true;
    _authStreamController.add(_currentUser);
  }

  /// Triggers Google OAuth sign-in flow
  Future<void> signInWithGoogle() async {
    if (AppConstants.isSupabaseConfigured && !isTestMode) {
      final String? webRedirectUrl = kIsWeb ? '${Uri.base.origin}/' : null;
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? webRedirectUrl : 'io.supabase.spellcraft://login-callback',
      );
    } else {
      // Realistic simulated Google login in test/dev mode for immediate UI & persistence testing
      final devUser = AppUser(
        id: 'dev-apprentice-777',
        email: 'apprentice@spellcraft.academy',
        displayName: 'Aria Spellweaver',
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      _currentUser = devUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_devSessionKey, jsonEncode(devUser.toJson()));
      _authStreamController.add(_currentUser);
    }
  }

  /// Terminates the user session and cleans up local storage
  Future<void> signOut() async {
    if (AppConstants.isSupabaseConfigured && !isTestMode) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signOut error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devSessionKey);

    _currentUser = null;
    _authStreamController.add(null);
  }

  AppUser _mapSupabaseUser(User user) {
    final meta = user.userMetadata ?? {};
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: (meta['full_name'] as String?) ??
          (meta['name'] as String?) ??
          (user.email?.split('@').first ?? 'Apprentice'),
      avatarUrl:
          (meta['avatar_url'] as String?) ?? (meta['picture'] as String?),
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  void dispose() {
    _authStreamController.close();
  }
}
