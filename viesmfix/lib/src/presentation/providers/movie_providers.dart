import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_entity.dart';
import 'app_providers.dart';
import '../../domain/repositories/movie_repository.dart';

// Trending Movies Provider
final trendingMoviesProvider = FutureProvider<List<MovieEntity>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getTrendingMovies();
});

// Popular Movies Provider
final popularMoviesProvider = FutureProvider<List<MovieEntity>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getPopularMovies();
});

// Upcoming Movies Provider
final upcomingMoviesProvider = FutureProvider<List<MovieEntity>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getUpcomingMovies();
});

// Now Playing Movies Provider
final nowPlayingMoviesProvider = FutureProvider<List<MovieEntity>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getNowPlayingMovies();
});

// Movie Details Provider (with family modifier for different movie IDs)
final movieDetailsProvider = FutureProvider.family<MovieDetailEntity, int>((
  ref,
  movieId,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getMovieDetails(movieId);
});

// Search Results Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<MovieEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repository = ref.watch(movieRepositoryProvider);
  return repository.searchMovies(query);
});

// Genres Provider
final genresProvider = FutureProvider<List<Genre>>((ref) async {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getGenres();
});

// Paginated feeds for home sections
class PaginatedMoviesNotifier
    extends StateNotifier<AsyncValue<List<MovieEntity>>> {
  final MovieRepository repository;
  final Future<List<MovieEntity>> Function(int page) fetcher;
  int _page = 1;

  PaginatedMoviesNotifier({required this.repository, required this.fetcher})
    : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final items = await fetcher(_page);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state;
    _page++;
    try {
      final nextItems = await fetcher(_page);
      final combined = [
        ...current.valueOrNull ?? const <MovieEntity>[],
        ...nextItems,
      ];
      state = AsyncValue.data(combined);
    } catch (e, st) {
      // rollback page on failure
      _page--;
      state = AsyncValue.error(e, st);
    }
  }
}

final trendingFeedProvider =
    StateNotifierProvider<
      PaginatedMoviesNotifier,
      AsyncValue<List<MovieEntity>>
    >((ref) {
      final repo = ref.watch(movieRepositoryProvider);
      return PaginatedMoviesNotifier(
        repository: repo,
        fetcher: (page) => repo.getTrendingMovies(page: page),
      );
    });

final popularFeedProvider =
    StateNotifierProvider<
      PaginatedMoviesNotifier,
      AsyncValue<List<MovieEntity>>
    >((ref) {
      final repo = ref.watch(movieRepositoryProvider);
      return PaginatedMoviesNotifier(
        repository: repo,
        fetcher: (page) => repo.getPopularMovies(page: page),
      );
    });

final upcomingFeedProvider =
    StateNotifierProvider<
      PaginatedMoviesNotifier,
      AsyncValue<List<MovieEntity>>
    >((ref) {
      final repo = ref.watch(movieRepositoryProvider);
      return PaginatedMoviesNotifier(
        repository: repo,
        fetcher: (page) => repo.getUpcomingMovies(page: page),
      );
    });

final nowPlayingFeedProvider =
    StateNotifierProvider<
      PaginatedMoviesNotifier,
      AsyncValue<List<MovieEntity>>
    >((ref) {
      final repo = ref.watch(movieRepositoryProvider);
      return PaginatedMoviesNotifier(
        repository: repo,
        fetcher: (page) => repo.getNowPlayingMovies(page: page),
      );
    });
