import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../services/api/tmdb_service.dart';
import '../mappers/movie_mapper.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TMDBService _tmdbService;

  MovieRepositoryImpl(this._tmdbService);

  @override
  Future<List<MovieEntity>> getTrendingMovies({int page = 1}) async {
    final response = await _tmdbService.getTrendingMovies(page: page);
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<List<MovieEntity>> getPopularMovies({int page = 1}) async {
    final response = await _tmdbService.getPopularMovies(page: page);
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<List<MovieEntity>> getUpcomingMovies({int page = 1}) async {
    final response = await _tmdbService.getUpcomingMovies(page: page);
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<List<MovieEntity>> getNowPlayingMovies({int page = 1}) async {
    final response = await _tmdbService.getNowPlayingMovies(page: page);
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<MovieDetailEntity> getMovieDetails(int movieId) async {
    final response = await _tmdbService.getMovieDetails(movieId);
    return MovieMapper.fromTMDBDetailModel(response);
  }

  @override
  Future<List<MovieEntity>> searchMovies(String query, {int page = 1}) async {
    final response = await _tmdbService.searchMovies(query: query, page: page);
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<List<MovieEntity>> discoverMovies({
    int page = 1,
    List<int>? withGenres,
    String? sortBy,
  }) async {
    final response = await _tmdbService.discoverMovies(
      page: page,
      withGenres: withGenres,
      sortBy: sortBy,
    );
    return MovieMapper.fromTMDBModelList(response.results);
  }

  @override
  Future<List<Genre>> getGenres() async {
    final response = await _tmdbService.getGenres();
    return response.map((g) => Genre(id: g.id, name: g.name)).toList();
  }
}
