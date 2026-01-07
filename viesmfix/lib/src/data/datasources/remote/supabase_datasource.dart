import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/watchlist_item_entity.dart';

/// Remote data source for Supabase
abstract class SupabaseDataSource {
  Future<User?> getCurrentUser();
  Future<UserEntity?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserEntity user);

  Future<List<WatchlistItemEntity>> getWatchlistItems(String userId);
  Future<void> addToWatchlist(String userId, int movieId);
  Future<void> removeFromWatchlist(String userId, int movieId);
  Future<void> updateWatchlistItem(WatchlistItemEntity item);

  Stream<List<WatchlistItemEntity>> watchWatchlistItems(String userId);
}

/// Implementation of Supabase data source
class SupabaseDataSourceImpl implements SupabaseDataSource {
  final SupabaseClient _client;

  SupabaseDataSourceImpl(this._client);

  @override
  Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserEntity(
        id: response['id'] as String,
        email: response['email'] as String,
        username: response['username'] as String?,
        avatarUrl: response['avatar_url'] as String?,
        bio: response['bio'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      await _client
          .from('profiles')
          .update({
            'username': user.username,
            'avatar_url': user.avatarUrl,
            'bio': user.bio,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<List<WatchlistItemEntity>> getWatchlistItems(String userId) async {
    try {
      final response = await _client
          .from('watchlist_items')
          .select()
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      return (response as List)
          .map(
            (json) => WatchlistItemEntity(
              id: json['id'] as String,
              userId: json['user_id'] as String,
              movieId: json['movie_id'] as int,
              movieTitle: json['movie_title'] as String,
              moviePosterPath: json['movie_poster_path'] as String?,
              addedAt: DateTime.parse(json['added_at'] as String),
              userRating: json['user_rating'] as double?,
              watched: json['watched'] as bool? ?? false,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch watchlist items: $e');
    }
  }

  @override
  Future<void> addToWatchlist(String userId, int movieId) async {
    try {
      await _client.from('watchlist_items').insert({
        'user_id': userId,
        'movie_id': movieId,
        'added_at': DateTime.now().toIso8601String(),
        'watched': false,
      });
    } catch (e) {
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  @override
  Future<void> removeFromWatchlist(String userId, int movieId) async {
    try {
      await _client
          .from('watchlist_items')
          .delete()
          .eq('user_id', userId)
          .eq('movie_id', movieId);
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  @override
  Future<void> updateWatchlistItem(WatchlistItemEntity item) async {
    try {
      await _client
          .from('watchlist_items')
          .update({'watched': item.watched, 'user_rating': item.userRating})
          .eq('id', item.id);
    } catch (e) {
      throw Exception('Failed to update watchlist item: $e');
    }
  }

  @override
  Stream<List<WatchlistItemEntity>> watchWatchlistItems(String userId) {
    return _client
        .from('watchlist_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('added_at', ascending: false)
        .map(
          (data) => data
              .map(
                (json) => WatchlistItemEntity(
                  id: json['id'] as String,
                  userId: json['user_id'] as String,
                  movieId: json['movie_id'] as int,
                  movieTitle: json['movie_title'] as String,
                  moviePosterPath: json['movie_poster_path'] as String?,
                  addedAt: DateTime.parse(json['added_at'] as String),
                  watched: json['watched'] as bool? ?? false,
                  userRating: json['user_rating'] as double?,
                ),
              )
              .toList(),
        );
  }
}
