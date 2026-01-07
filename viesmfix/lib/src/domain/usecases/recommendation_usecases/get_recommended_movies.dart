import '../../entities/movie_entity.dart';
import '../../repositories/movie_repository.dart';

/// Use case for getting personalized movie recommendations
class GetRecommendedMovies {
  final MovieRepository _repository;

  GetRecommendedMovies(this._repository);

  /// Get recommended movies based on user's watch history and ratings
  ///
  /// This uses a simple collaborative filtering approach:
  /// 1. Get user's highly rated movies (>= 4.0)
  /// 2. For each highly rated movie, get similar movies from TMDB
  /// 3. Score and rank recommendations by relevance
  /// 4. Filter out movies user has already seen
  Future<List<MovieEntity>> execute({
    List<int>? watchedMovieIds,
    List<int>? highlyRatedMovieIds,
    int limit = 20,
  }) async {
    if (highlyRatedMovieIds == null || highlyRatedMovieIds.isEmpty) {
      // If no rating history, return trending movies
      return await _repository.getTrendingMovies(page: 1);
    }

    final recommendationScores = <int, double>{};
    final movieCache = <int, MovieEntity>{};

    // Get similar movies for each highly rated movie
    for (final movieId in highlyRatedMovieIds.take(5)) {
      // Limit to prevent too many API calls
      try {
        final details = await _repository.getMovieDetails(movieId);

        // Get similar movies
        final similarMovies = details.similar;

        for (final movie in similarMovies) {
          // Skip if user has already watched this movie
          if (watchedMovieIds != null && watchedMovieIds.contains(movie.id)) {
            continue;
          }

          // Calculate score based on popularity and rating
          final score = _calculateRecommendationScore(
            movie,
            isFromHighlyRated: true,
          );

          // Accumulate scores for movies recommended from multiple sources
          recommendationScores[movie.id] =
              (recommendationScores[movie.id] ?? 0.0) + score;

          movieCache[movie.id] = movie;
        }
      } catch (e) {
        // Continue with other movies if one fails
        continue;
      }
    }

    // Sort by score and take top N
    final sortedMovieIds = recommendationScores.keys.toList()
      ..sort(
        (a, b) => recommendationScores[b]!.compareTo(recommendationScores[a]!),
      );

    final recommendations = sortedMovieIds
        .take(limit)
        .map((id) => movieCache[id]!)
        .toList();

    // If we don't have enough recommendations, fill with popular movies
    if (recommendations.length < limit) {
      final popularMovies = await _repository.getPopularMovies(page: 1);
      final additionalMovies = popularMovies
          .where(
            (movie) =>
                !recommendationScores.containsKey(movie.id) &&
                (watchedMovieIds == null ||
                    !watchedMovieIds.contains(movie.id)),
          )
          .take(limit - recommendations.length);

      recommendations.addAll(additionalMovies);
    }

    return recommendations;
  }

  /// Calculate recommendation score for a movie
  double _calculateRecommendationScore(
    MovieEntity movie, {
    required bool isFromHighlyRated,
  }) {
    double score = 0.0;

    // Base score from popularity (normalized to 0-10)
    final popularityScore = (movie.popularity ?? 0.0) / 100.0;
    score += popularityScore;

    // Add rating score (0-10)
    final ratingScore = movie.voteAverage ?? 0.0;
    score += ratingScore;

    // Boost score if it's from a highly rated movie
    if (isFromHighlyRated) {
      score *= 1.5;
    }

    // Slight penalty for very old movies (more than 10 years)
    if (movie.releaseDate != null) {
      final yearsOld =
          DateTime.now().year - int.parse(movie.releaseDate!.split('-')[0]);
      if (yearsOld > 10) {
        score *= 0.9;
      }
    }

    return score;
  }
}
