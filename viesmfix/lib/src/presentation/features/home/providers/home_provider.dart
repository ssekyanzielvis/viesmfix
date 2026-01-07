import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/movie_entity.dart';
import '../../../app_providers.dart';

/// Trending movies provider
final trendingMoviesProvider = FutureProvider.autoDispose<List<MovieEntity>>((
  ref,
) async {
  final useCase = ref.watch(getTrendingMoviesProvider);
  return await useCase();
});

/// Now playing movies provider
final nowPlayingMoviesProvider = FutureProvider.autoDispose<List<MovieEntity>>((
  ref,
) async {
  final useCase = ref.watch(getNowPlayingMoviesProvider);
  return await useCase();
});

/// Popular movies provider
final popularMoviesProvider = FutureProvider.autoDispose<List<MovieEntity>>((
  ref,
) async {
  final useCase = ref.watch(getPopularMoviesProvider);
  return await useCase();
});

/// Upcoming movies provider
final upcomingMoviesProvider = FutureProvider.autoDispose<List<MovieEntity>>((
  ref,
) async {
  final useCase = ref.watch(getUpcomingMoviesProvider);
  return await useCase();
});

/// Featured movie provider (first trending movie)
final featuredMovieProvider = FutureProvider.autoDispose<MovieEntity?>((
  ref,
) async {
  final trending = await ref.watch(trendingMoviesProvider.future);
  return trending.isNotEmpty ? trending.first : null;
});
