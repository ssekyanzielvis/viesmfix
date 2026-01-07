import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    } catch (e) {
      throw AuthenticationException('Failed to get current user: $e');
    }
  }

  @override
  Future<UserEntity?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthenticationException.invalidCredentials();
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Sign in failed: $e');
    }
  }

  @override
  Future<UserEntity?> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );

      final user = response.user;
      if (user == null) {
        throw AuthenticationException('Sign up failed');
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username: username,
        avatarUrl: null,
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw AuthenticationException.emailAlreadyExists();
      }
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Sign up failed: $e');
    }
  }

  Future<UserEntity> signInWithGoogle() async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'app://login-callback',
      );

      if (!response) {
        throw AuthenticationException('Google sign in cancelled');
      }

      // Wait for auth state change
      await Future.delayed(const Duration(seconds: 1));

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('Google sign in failed');
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username:
            user.userMetadata?['username'] ??
            user.email?.split('@').first ??
            '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Google sign in failed: $e');
    }
  }

  Future<UserEntity> signInWithApple() async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'app://login-callback',
      );

      if (!response) {
        throw AuthenticationException('Apple sign in cancelled');
      }

      // Wait for auth state change
      await Future.delayed(const Duration(seconds: 1));

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('Apple sign in failed');
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username:
            user.userMetadata?['username'] ??
            user.email?.split('@').first ??
            '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Apple sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Password reset failed: $e');
    }
  }

  Future<UserEntity> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(data: updates),
      );

      final user = response.user;
      if (user == null) {
        throw AuthenticationException('Profile update failed');
      }

      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        username: user.userMetadata?['username'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
        createdAt: DateTime.parse(user.createdAt),
      );
    } on AuthException catch (e) {
      throw AuthenticationException(e.message);
    } catch (e) {
      throw AuthenticationException('Profile update failed: $e');
    }
  }
}
