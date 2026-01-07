import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity?> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  });

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
