import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetNowPlayingMovies {
  final MovieRepository _repository;

  GetNowPlayingMovies(this._repository);

  Future<List<MovieEntity>> call({int page = 1}) async {
    return await _repository.getNowPlayingMovies(page: page);
  }
}
