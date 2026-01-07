import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/watchlist_item_entity.dart';
import '../../../app_providers.dart';

/// Watchlist count provider
final watchlistCountProvider = Provider<int>((ref) {
  final watchlist = ref.watch(watchlistStreamProvider);
  return watchlist.when(
    data: (items) => items.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Watchlist sort options
enum WatchlistSort { dateAdded, title, releaseDate, rating }

/// Watchlist sort provider
final watchlistSortProvider = StateProvider<WatchlistSort>((ref) {
  return WatchlistSort.dateAdded;
});

/// Sorted watchlist provider
final sortedWatchlistProvider = Provider<List<WatchlistItemEntity>>((ref) {
  final watchlistState = ref.watch(watchlistStreamProvider);
  final sortBy = ref.watch(watchlistSortProvider);

  return watchlistState.when(
    data: (items) {
      final sorted = List<WatchlistItemEntity>.from(items);

      switch (sortBy) {
        case WatchlistSort.dateAdded:
          sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
          break;
        case WatchlistSort.title:
          sorted.sort((a, b) => a.movieTitle.compareTo(b.movieTitle));
          break;
        case WatchlistSort.releaseDate:
          // Keep items sorted by date added as fallback since no releaseDate on entity
          sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
          break;
        case WatchlistSort.rating:
          sorted.sort(
            (a, b) => (b.userRating ?? 0.0).compareTo(a.userRating ?? 0.0),
          );
          break;
      }

      return sorted;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
