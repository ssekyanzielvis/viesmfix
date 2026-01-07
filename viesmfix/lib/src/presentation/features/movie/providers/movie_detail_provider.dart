import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../app_providers.dart';

/// Movie details provider with caching
final movieDetailsProvider = FutureProvider.family
    .autoDispose<MovieEntity, int>((ref, movieId) async {
      final useCase = ref.watch(getMovieDetailsProvider);
      return await useCase(movieId);
    });

/// Similar movies provider
final similarMoviesProvider = FutureProvider.family
    .autoDispose<List<MovieEntity>, int>((ref, movieId) async {
      // TODO: Implement similar movies use case
      // For now, return trending movies as placeholder
      final trending = ref.watch(getTrendingMoviesProvider);
      return await trending(page: 1);
    });

/// Movie cast provider
final movieCastProvider = FutureProvider.family.autoDispose<List<dynamic>, int>(
  (ref, movieId) async {
    // TODO: Implement cast use case when TMDB model includes credits
    return [];
  },
);

/// Movie videos provider (trailers, teasers)
final movieVideosProvider = FutureProvider.family
    .autoDispose<List<dynamic>, int>((ref, movieId) async {
      // TODO: Implement videos use case when TMDB model includes videos
      return [];
    });

/// Is movie in watchlist provider
final isInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final watchlistIds = ref.watch(watchlistIdsProvider);
  return watchlistIds.contains(movieId);
});
