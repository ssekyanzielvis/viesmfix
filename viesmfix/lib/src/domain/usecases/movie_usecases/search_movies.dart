import '../../../domain/entities/movie_entity.dart';
import '../../../domain/repositories/movie_repository.dart';

class SearchMovies {
  final MovieRepository repository;

  SearchMovies(this.repository);

  Future<List<MovieEntity>> execute(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Note: includeAdult parameter is ignored as the repository doesn't support it
    return await repository.searchMovies(query, page: page);
  }
}
