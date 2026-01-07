import '../entities/watchlist_item_entity.dart';

abstract class WatchlistRepository {
  Future<List<WatchlistItemEntity>> getWatchlist(String userId);
  Stream<List<WatchlistItemEntity>> watchWatchlist(String userId);
  Future<void> addToWatchlist(WatchlistItemEntity item);
  Future<void> removeFromWatchlist(String userId, int movieId);
  Future<bool> isInWatchlist(String userId, int movieId);
  Future<void> updateRating(String userId, int movieId, double rating);
  Future<void> markAsWatched(String userId, int movieId, bool watched);
}
