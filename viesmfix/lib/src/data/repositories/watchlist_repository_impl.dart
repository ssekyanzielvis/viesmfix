import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../../domain/entities/watchlist_item_entity.dart';
import '../../core/errors/exceptions.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final SupabaseClient _supabaseClient;

  WatchlistRepositoryImpl(this._supabaseClient);

  @override
  Future<List<WatchlistItemEntity>> getWatchlist(String userId) async {
    try {
      final response = await _supabaseClient
          .from('watchlist_items')
          .select('id, user_id, movie_id, created_at, rating, watched')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Fetch movie details separately
      final List<WatchlistItemEntity> items = [];
      for (final item in response as List) {
        final movieResponse = await _supabaseClient
            .from('movies')
            .select('id, title, poster_path')
            .eq('id', item['movie_id'])
            .maybeSingle();

        items.add(
          WatchlistItemEntity(
            id: item['id'],
            userId: item['user_id'],
            movieId: item['movie_id'],
            movieTitle: movieResponse?['title'] ?? 'Unknown',
            moviePosterPath: movieResponse?['poster_path'],
            addedAt: DateTime.parse(item['created_at']),
            userRating: item['rating']?.toDouble(),
            watched: item['watched'],
          ),
        );
      }
      return items;
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get watchlist: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get watchlist: $e');
    }
  }

  @override
  Future<void> addToWatchlist(WatchlistItemEntity item) async {
    final userId = item.userId;
    final movieId = item.movieId;
    try {
      // Add to watchlist directly - Supabase will handle the movie data insertion
      // The movie data should be available from TMDB and synced separately
      await _supabaseClient.from('watchlist_items').insert({
        'user_id': userId,
        'movie_id': movieId,
        'added_at': item.addedAt.toIso8601String(),
        'user_rating': item.userRating,
        'watched': item.watched ?? false,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - already in watchlist
        return;
      }
      throw ServerException('Failed to add to watchlist: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to add to watchlist: $e');
    }
  }

  @override
  Future<void> removeFromWatchlist(String userId, int movieId) async {
    try {
      await _supabaseClient
          .from('watchlist_items')
          .delete()
          .eq('user_id', userId)
          .eq('movie_id', movieId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to remove from watchlist: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to remove from watchlist: $e');
    }
  }

  @override
  Future<bool> isInWatchlist(String userId, int movieId) async {
    try {
      final result = await _supabaseClient
          .from('watchlist_items')
          .select('id')
          .eq('user_id', userId)
          .eq('movie_id', movieId)
          .maybeSingle();

      return result != null;
    } on PostgrestException catch (e) {
      throw ServerException('Failed to check watchlist: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to check watchlist: $e');
    }
  }

  @override
  Future<void> updateRating(String userId, int movieId, double rating) async {
    try {
      await _supabaseClient
          .from('watchlist_items')
          .update({'rating': rating})
          .eq('user_id', userId)
          .eq('movie_id', movieId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update rating: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update rating: $e');
    }
  }

  @override
  Future<void> markAsWatched(String userId, int movieId, bool watched) async {
    try {
      await _supabaseClient
          .from('watchlist_items')
          .update({'watched': watched})
          .eq('user_id', userId)
          .eq('movie_id', movieId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to mark as watched: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to mark as watched: $e');
    }
  }

  @override
  Stream<List<WatchlistItemEntity>> watchWatchlist(String userId) {
    return _supabaseClient
        .from('watchlist_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final List<WatchlistItemEntity> items = [];
          for (final item in data) {
            final movieResponse = await _supabaseClient
                .from('movies')
                .select('id, title, poster_path')
                .eq('id', item['movie_id'])
                .maybeSingle();

            items.add(
              WatchlistItemEntity(
                id: item['id'],
                userId: item['user_id'],
                movieId: item['movie_id'],
                movieTitle: movieResponse?['title'] ?? 'Unknown',
                moviePosterPath: movieResponse?['poster_path'],
                addedAt: DateTime.parse(item['created_at']),
                userRating: item['rating']?.toDouble(),
                watched: item['watched'],
              ),
            );
          }
          return items;
        });
  }
}
