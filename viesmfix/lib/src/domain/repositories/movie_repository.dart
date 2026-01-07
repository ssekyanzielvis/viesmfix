import '../entities/movie_entity.dart';

abstract class MovieRepository {
  Future<List<MovieEntity>> getTrendingMovies({int page = 1});
  Future<List<MovieEntity>> getPopularMovies({int page = 1});
  Future<List<MovieEntity>> getUpcomingMovies({int page = 1});
  Future<List<MovieEntity>> getNowPlayingMovies({int page = 1});
  Future<MovieDetailEntity> getMovieDetails(int movieId);
  Future<List<MovieEntity>> searchMovies(String query, {int page = 1});
  Future<List<MovieEntity>> discoverMovies({
    int page = 1,
    List<int>? withGenres,
    String? sortBy,
  });
  Future<List<Genre>> getGenres();
}
