import '../../entities/movie_entity.dart';
import '../../repositories/movie_repository.dart';

class GetPopularMovies {
  final MovieRepository repository;

  GetPopularMovies(this.repository);

  Future<List<MovieEntity>> execute({int page = 1}) async {
    return await repository.getPopularMovies(page: page);
  }
}
