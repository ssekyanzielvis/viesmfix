import '../../../domain/entities/movie_entity.dart';
import '../../../domain/repositories/movie_repository.dart';

class GetTrendingMovies {
  final MovieRepository repository;

  GetTrendingMovies(this.repository);

  Future<List<MovieEntity>> execute({
    String timeWindow = 'week',
    int page = 1,
  }) async {
    // Note: timeWindow parameter is ignored as the repository doesn't support it
    // All trending movies are fetched using the default time window
    return await repository.getTrendingMovies(page: page);
  }
}
