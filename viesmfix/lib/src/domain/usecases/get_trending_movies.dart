import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetTrendingMovies {
  final MovieRepository _repository;

  GetTrendingMovies(this._repository);

  Future<List<MovieEntity>> call({int page = 1}) async {
    return await _repository.getTrendingMovies(page: page);
  }
}
