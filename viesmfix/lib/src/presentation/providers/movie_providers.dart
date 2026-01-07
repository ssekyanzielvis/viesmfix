import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_entity.dart';
import 'app_providers.dart';

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
