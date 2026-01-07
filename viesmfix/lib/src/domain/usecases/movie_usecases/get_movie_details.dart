import '../../../domain/entities/movie_entity.dart';
import '../../../domain/repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<MovieDetailEntity> execute(int movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}
