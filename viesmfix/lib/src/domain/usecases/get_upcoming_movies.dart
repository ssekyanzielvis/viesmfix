import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetUpcomingMovies {
  final MovieRepository _repository;

  GetUpcomingMovies(this._repository);

  Future<List<MovieEntity>> call({int page = 1}) async {
    return await _repository.getUpcomingMovies(page: page);
  }
}
