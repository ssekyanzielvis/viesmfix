import '../entities/user_entity.dart';

/// Abstract repository interface for user operations
abstract class UserRepository {
  /// Get user profile by ID
  Future<UserEntity> getUserProfile(String userId);

  /// Update user profile
  Future<UserEntity> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  });

  /// Delete user account
  Future<void> deleteAccount(String userId);

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences(String userId);

  /// Update user preferences
  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  });

  /// Get user statistics
  Future<UserStats> getUserStats(String userId);
}

/// User statistics model
class UserStats {
  final int moviesWatched;
  final int moviesRated;
  final int watchlistCount;
  final int reviewsCount;
  final int followersCount;
  final int followingCount;

  const UserStats({
    required this.moviesWatched,
    required this.moviesRated,
    required this.watchlistCount,
    required this.reviewsCount,
    required this.followersCount,
    required this.followingCount,
  });
}
