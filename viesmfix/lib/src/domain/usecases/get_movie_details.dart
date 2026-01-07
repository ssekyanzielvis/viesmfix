import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository _repository;

  GetMovieDetails(this._repository);

  Future<MovieDetailEntity> call(int movieId) async {
    return await _repository.getMovieDetails(movieId);
  }
}
