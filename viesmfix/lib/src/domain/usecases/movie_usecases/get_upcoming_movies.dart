import '../../entities/movie_entity.dart';
import '../../repositories/movie_repository.dart';

class GetUpcomingMovies {
  final MovieRepository repository;

  GetUpcomingMovies(this.repository);

  Future<List<MovieEntity>> execute({int page = 1}) async {
    return await repository.getUpcomingMovies(page: page);
  }
}
