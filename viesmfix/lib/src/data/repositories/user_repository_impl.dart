import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;

  UserRepositoryImpl(this._supabase);

  @override
  Future<UserEntity> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return _mapToUserEntity(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserEntity> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return _mapToUserEntity(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      // Delete user profile (auth user will be handled by trigger)
      await _supabase.from('profiles').delete().eq('id', userId);

      // Sign out current user
      await _supabase.auth.signOut();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to delete account: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('preferences')
          .eq('id', userId)
          .single();

      return (response['preferences'] as Map<String, dynamic>?) ?? {};
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> updateUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .update({'preferences': preferences})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to update user preferences: $e');
    }
  }

  @override
  Future<UserStats> getUserStats(String userId) async {
    try {
      // Get watchlist count
      final watchlistResponse = await _supabase
          .from('watchlist_items')
          .select()
          .eq('user_id', userId)
          .count();

      // TODO: Add queries for other stats when tables are created
      return UserStats(
        moviesWatched: 0,
        moviesRated: 0,
        watchlistCount: watchlistResponse.count,
        reviewsCount: 0,
        followersCount: 0,
        followingCount: 0,
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException('Failed to get user stats: $e');
    }
  }

  UserEntity _mapToUserEntity(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'] as String,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
