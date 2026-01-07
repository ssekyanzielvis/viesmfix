import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Authentication state
class AuthState {
  final User? user;
  final UserEntity? userProfile;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.userProfile,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    UserEntity? userProfile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          user?.id == other.user?.id &&
          userProfile?.id == other.userProfile?.id &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      user.hashCode ^
      userProfile.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}

/// Auth state provider that watches Supabase auth state changes
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState()) {
    _initialize();
  }

  final _supabase = Supabase.instance.client;

  void _initialize() {
    // Set initial state
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      state = AuthState(user: currentUser);
      _loadUserProfile(currentUser.id);
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            state = AuthState(user: session!.user);
            _loadUserProfile(session.user.id);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = const AuthState();
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            state = state.copyWith(user: session!.user);
            _loadUserProfile(session.user.id);
          }
          break;
        case AuthChangeEvent.tokenRefreshed:
          if (session?.user != null) {
            state = state.copyWith(user: session!.user);
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final userProfile = UserEntity(
        id: response['id'] as String,
        email: response['email'] as String,
        username: response['username'] as String?,
        avatarUrl: response['avatar_url'] as String?,
        bio: response['bio'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
      );

      state = state.copyWith(userProfile: userProfile);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load user profile: $e');
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _supabase.auth.signInWithPassword(email: email, password: password);
      // Auth state change listener will update state
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to sign in: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
        });
      }
      // Auth state change listener will update state
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to sign up: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      // Auth state change listener will update state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign in with Google: $e',
      );
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _supabase.auth.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to sign out: $e');
    }
  }

  /// Refresh the current user's profile
  Future<void> refreshProfile() async {
    final userId = state.user?.id;
    if (userId != null) {
      await _loadUserProfile(userId);
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Global auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// Provider for the current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

/// Provider for the current user profile
final currentUserProfileProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).userProfile;
});

/// Provider for auth loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

/// Provider for auth error
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});
