import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/watchlist_repository_impl.dart';
import '../../domain/entities/watchlist_item_entity.dart';
import '../../services/supabase_service.dart';
import '../features/auth/providers/auth_provider.dart';

// Watchlist repository provider
final watchlistRepositoryProvider = Provider((ref) {
  return WatchlistRepositoryImpl(SupabaseService.instance.client);
});

// Watchlist provider
final watchlistProvider = StreamProvider<List<WatchlistItemEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(watchlistRepositoryProvider);
  return repository.watchWatchlist(user.id);
});

// Watchlist state provider for quick access
final watchlistIdsProvider = Provider<Set<int>>((ref) {
  final watchlistState = ref.watch(watchlistProvider);
  return watchlistState.when(
    data: (items) => items.map((item) => item.movieId).toSet(),
    loading: () => {},
    error: (_, __) => {},
  );
});

// Watchlist actions provider
final watchlistActionsProvider = Provider((ref) {
  return WatchlistActions(
    repository: ref.watch(watchlistRepositoryProvider),
    getUser: () {
      final authState = ref.read(authStateProvider);
      return authState.user?.id;
    },
  );
});

class WatchlistActions {
  final WatchlistRepositoryImpl repository;
  final String? Function() getUser;

  WatchlistActions({required this.repository, required this.getUser});

  Future<void> toggleWatchlist(
    int movieId,
    Map<String, dynamic> movieData,
  ) async {
    final userId = getUser();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final isInWatchlist = await repository.isInWatchlist(userId, movieId);

    if (isInWatchlist) {
      await repository.removeFromWatchlist(userId, movieId);
    } else {
      // Create WatchlistItemEntity from movie data
      final item = WatchlistItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        movieId: movieId,
        movieTitle: movieData['title'] ?? 'Unknown',
        moviePosterPath: movieData['poster_path'],
        addedAt: DateTime.now(),
      );
      await repository.addToWatchlist(item);
    }
  }

  Future<bool> isInWatchlist(int movieId) async {
    final userId = getUser();
    if (userId == null) return false;

    return await repository.isInWatchlist(userId, movieId);
  }

  Future<void> addToWatchlist(
    int movieId,
    Map<String, dynamic> movieData,
  ) async {
    final userId = getUser();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final item = WatchlistItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      movieId: movieId,
      movieTitle: movieData['title'] ?? 'Unknown',
      moviePosterPath: movieData['poster_path'],
      addedAt: DateTime.now(),
    );
    await repository.addToWatchlist(item);
  }

  Future<void> removeFromWatchlist(int movieId) async {
    final userId = getUser();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await repository.removeFromWatchlist(userId, movieId);
  }
}
