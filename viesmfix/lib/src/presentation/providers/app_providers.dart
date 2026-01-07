import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api/tmdb_service.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';

// TMDB Service Provider
final tmdbServiceProvider = Provider<TMDBService>((ref) {
  return TMDBService();
});

// Movie Repository Provider
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return MovieRepositoryImpl(tmdbService);
});
