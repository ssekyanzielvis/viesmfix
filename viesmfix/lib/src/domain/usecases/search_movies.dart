import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class SearchMovies {
  final MovieRepository _repository;

  SearchMovies(this._repository);

  Future<List<MovieEntity>> call(String query, {int page = 1}) async {
    return await _repository.searchMovies(query, page: page);
  }
}
