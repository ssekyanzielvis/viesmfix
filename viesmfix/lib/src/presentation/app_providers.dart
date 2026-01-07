import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/database_helper.dart';
import '../data/datasources/remote/tmdb_api_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/movie_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/watchlist_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/movie_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/watchlist_repository.dart';
import '../domain/usecases/get_movie_details.dart';
import '../domain/usecases/get_now_playing_movies.dart';
import '../domain/usecases/get_popular_movies.dart';
import '../domain/usecases/get_trending_movies.dart';
import '../domain/usecases/get_upcoming_movies.dart';
import '../domain/usecases/search_movies.dart';
import '../domain/usecases/user_usecases/get_user_profile.dart';
import '../services/api/tmdb_service.dart';
import '../services/supabase_service.dart';
import './providers/auth_state_provider.dart';

// ============================================================================
// DATA SOURCES
// ============================================================================

/// TMDB Service Provider
final tmdbServiceProvider = Provider<TMDBService>((ref) {
  return TMDBService();
});

/// TMDB API Service Provider
final tmdbApiServiceProvider = Provider<TmdbApiService>((ref) {
  return TmdbApiService();
});

/// Database Helper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Supabase Client Provider
final supabaseClientProvider = Provider((ref) {
  return SupabaseService.instance.client;
});

// ============================================================================
// REPOSITORIES
// ============================================================================

/// Movie Repository Provider
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(ref.watch(tmdbServiceProvider));
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Watchlist Repository Provider
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(supabaseClientProvider));
});

// ============================================================================
// USE CASES
// ============================================================================

/// Get Trending Movies Use Case
final getTrendingMoviesProvider = Provider<GetTrendingMovies>((ref) {
  return GetTrendingMovies(ref.watch(movieRepositoryProvider));
});

/// Search Movies Use Case
final searchMoviesProvider = Provider<SearchMovies>((ref) {
  return SearchMovies(ref.watch(movieRepositoryProvider));
});

/// Get Movie Details Use Case
final getMovieDetailsProvider = Provider<GetMovieDetails>((ref) {
  return GetMovieDetails(ref.watch(movieRepositoryProvider));
});

/// Get Popular Movies Use Case
final getPopularMoviesProvider = Provider<GetPopularMovies>((ref) {
  return GetPopularMovies(ref.watch(movieRepositoryProvider));
});

/// Get Now Playing Movies Use Case
final getNowPlayingMoviesProvider = Provider<GetNowPlayingMovies>((ref) {
  return GetNowPlayingMovies(ref.watch(movieRepositoryProvider));
});

/// Get Upcoming Movies Use Case
final getUpcomingMoviesProvider = Provider<GetUpcomingMovies>((ref) {
  return GetUpcomingMovies(ref.watch(movieRepositoryProvider));
});

/// Get User Profile Use Case
final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.watch(userRepositoryProvider));
});

// ============================================================================
// AUTH STATE
// ============================================================================
// Note: authStateProvider is defined in providers/auth_state_provider.dart

/// Current User Provider
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// ============================================================================
// WATCHLIST STATE
// ============================================================================

/// Watchlist Stream Provider
final watchlistStreamProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(watchlistRepositoryProvider).watchWatchlist(user.id);
});

/// Watchlist IDs Set Provider (for quick lookup)
final watchlistIdsProvider = Provider<Set<int>>((ref) {
  final watchlistState = ref.watch(watchlistStreamProvider);
  return watchlistState.when(
    data: (items) => items.map((item) => item.movieId as int).toSet(),
    loading: () => {},
    error: (_, __) => {},
  );
});

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Network Status Provider
final networkStatusProvider = StateProvider<bool>((ref) => true);

/// Theme Mode Provider
final themeModeProvider = StateProvider<bool>(
  (ref) => false,
); // false = light, true = dark

/// Selected Language Provider
final selectedLanguageProvider = StateProvider<String>((ref) => 'en-US');
